extends CharacterBody2D
class_name Hades

signal fall

@onready var movement: MovementComponent = $MovementComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var sprite: Sprite2D = $"EndBoss(ver2)"
@onready var water_detector: LavaWaterDetector = $LavaWater_Detector
@onready var cooldown_timer: Timer = $cooldown_timer
@onready var health_comp: HealthComponent = $healthComponent

@onready var wave_component: Array[WaveComponent] = [$wave_component_left, $wave_component_right]

enum Attack {SPEAR, AXT}
var attack: Attack = Attack.AXT


enum State {IDLE, DASHING, FALLING, AIR, FINISH_ANIMATION}
var state: State = State.IDLE

var distance: String = ""

func _ready() -> void:
	G.boss_begin.emit("Hades", 100)
	health_comp.value_changed.connect(set_health_bar)
#	died()
	movement.setup(self, water_detector)
	animation_player.play("Warning")
	health_comp.died.connect(died)

func set_health_bar() -> void:
	G.boss_value_changed.emit(health_comp.health / health_comp.max_health * 100)
	animation_player.play("Damage")

func _physics_process(delta: float) -> void:
	match state:
		State.FINISH_ANIMATION:
			return
		
		State.IDLE:
			if player_detector.focus_player == null:
				return
			
			sprite.flip_h = player_detector.focus_player.global_position.x > global_position.x
		
		State.DASHING:
			movement.move_horizontal(1 if sprite.flip_h else -1)
			if is_on_wall():
				state = State.FINISH_ANIMATION
				fall.emit()
	
		State.FALLING:
			if is_on_floor():
				state = State.FINISH_ANIMATION
				for wave: WaveComponent in wave_component:
					wave.shoot_wave()
				return
			
			movement.apply_gravity(delta)
		
		State.AIR:
			movement.apply_gravity(delta)
			if not state == State.FALLING and velocity.y > 0:
					velocity.y = 0
	
	move_and_slide()

func _on_cooldown_timer_timeout() -> void:
	animation_player.play("Warning")


func choose_attack() -> void:
	if player_detector.focus_player == null:
		push_warning("No Player inside player_detector. doing far attack")
		do_attack(false)
		return
	
	var distance_value: float = player_detector.focus_player.global_position.distance_to(global_position)
	do_attack(distance_value < 50)


func jump() -> void:
	state = State.AIR
	movement.jump()


func falling() -> void:
	state = State.FALLING
	global_position.x = player_detector.focus_player.global_position.x


func dash() -> void:
	if distance == "Far":
		state = State.DASHING


func do_attack(close: bool) -> void:
	distance = "Close" if close else "Far"
	var side: String = "Right" if sprite.flip_h else "Left"
	
	match attack:
		Attack.AXT:
			animation_player.play("Axt_"+ distance + "_" + side)
			attack = Attack.SPEAR
			
		Attack.SPEAR:
			animation_player.play("Spear_Close_" + side)
			attack = Attack.AXT



func died() -> void:
	if Save.player.deaths[G.active_slot] == 0:
		var achievment_comp: AchievmentComponent = $achievmentComponent
		achievment_comp.add_achievment()
	
	
	var transition_comp: LevelTransition = $LeveltransitionComponent
	transition_comp.transition()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if not anim_name == "Warning" or anim_name == "Damage":
		state = State.IDLE
		player_detector.changeTarget()
		cooldown_timer.start(randi_range(2, 4))
		return
	
	if anim_name == "Warning":
		choose_attack()
