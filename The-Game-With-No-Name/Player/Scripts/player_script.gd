extends CharacterBody2D
class_name Player

const MAX_FLOOR_ANGLE: float = PI / 4.0

#Components
@onready var health_component: HealthComponent = $healthComponent
@onready var rotater_component: FloorRotaterComponent = $FloorRotaterComponent
@onready var push_component: PushComponent = $PushComponent
@onready var airship_entry_component: AirshipEntryComponent = $AirshipEntryComponent

@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D

@onready var lava_water_detector: LavaWaterDetector = $LavaWaterDetector

@onready var grab_zone: GrabZone = $GrabZone
@onready var hurtbox: HurtBox = $Hurtbox
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var reset_comp: EnemyResetComponent = $ResetComponent

#Player Components
@onready var movement: MovementComponent = $PlayerMovement
@onready var animation: PlayerAnimation = $PlayerAnimation
@onready var combat: PlayerCombat = $PlayerCombat
@onready var input: PlayerInput = $PlayerInput

@onready var sword: Sword = $Sword
@onready var wand: Wand = $Wand
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var state_machine: StateMachine = $StateMachine

@export var current_player: int = 0

var is_alive: bool = true
var launch_direction: Vector2 = Vector2()

func _ready() -> void:
	combat.player_index =  current_player
	_setup_components()
	_connect_signals()
	_configure_floor_settings()
	_setup_battle()
	state_machine.setup(self)
	
	state_machine.change_state(PlayerStates.ID.GROUND)

#region setups

func _setup_battle() -> void:
	if not BattleData.battle:
		return
	
	hurtbox.set_collision_layer_value(3, true)
	set_collision_layer_value(1, true)


func _setup_components() -> void:
	input.setup(current_player + 1)
	movement.setup(self)
	animation.setup(current_player, animated_sprite)
	combat.setup(sword, wand)
	push_component.setup(self)
	airship_entry_component.setup(self)


func _configure_floor_settings() -> void:
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(MAX_FLOOR_ANGLE)
	floor_constant_speed = true
	slide_on_ceiling = false


func _connect_signals() -> void:
	health_component.value_changed.connect(_on_value_changed)
	health_component.died.connect(respawn)
	reset_comp.disabling_stats.connect(freeze)
	reset_comp.enabling_stats.connect(enable_player)
	lava_water_detector.lava_entered.connect(lava_entered)

#endregion

#region helper
func un_freeze() -> void:
	state_machine.change_state(PlayerStates.ID.GROUND)

func freeze() -> void:
	state_machine.change_state(PlayerStates.ID.FREEZE)

func is_in_state(id: PlayerStates.ID) -> bool:
	return state_machine.is_in_state(id)
#endregion

#region camera
func connect_camera(camera: NodePath) -> void:
	remote_transform.remote_path = camera


func disconnect_camera() -> NodePath:
	var camera: NodePath = remote_transform.remote_path
	remote_transform.remote_path = ""
	
	return camera
#endregion

#region lava

func lava_entered(entered: bool) -> void:
	if not entered:
		return
	
	if not BattleData.battle:
		health_component.die()
		return
	
	_apply_lava_damage()

func _apply_lava_damage() -> void:
	var hit: HitData = HitData.new()
	hit.damage = 20
	hit.damage_type = hit.DamageType.LAVA
	hit.knockback_force = 200
	hit.source = self
	hit.knockback_type = hit.KnockbackType.UP
	
	hurtbox.receive_hit(hit)

#endregion
func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	state_machine.physics_update(delta)
	
	push_component.push()


func respawn() -> void:
	is_alive = false
	animation.play(animation.Anim.DEAD)


func enable_player() -> void:
	is_alive = true
	grab_zone.rope_part = null
	state_machine.change_state(PlayerStates.ID.GROUND)
	grab_zone.can_grab = true
	velocity = Vector2.ZERO
	health_component.health = 100
	G.health_value_changed.emit(current_player, 100)
	G.mana_value_changed.emit(current_player, 100)

#region Wall
func next_to_wall() -> bool:
	return (
		next_to_right_wall() 
		or next_to_left_wall() 
		or is_on_wall()
	)


func next_to_right_wall() -> bool:
	return raycast_right.is_colliding()


func next_to_left_wall() -> bool: 
	return raycast_left.is_colliding()
#endregion

#region Signal Callbacks
func _on_AnimatedSprite_animation_finished() -> void:
	if is_alive:
		return
	
	reset_comp.disable_stats()
	G.player_died.emit(current_player)


func _on_value_changed() -> void:
	G.health_value_changed.emit(current_player, health_component.health)
#endregion
