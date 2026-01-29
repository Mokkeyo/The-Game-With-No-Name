extends CharacterBody2D

@onready var RayCast: RayCast2D = $RayCast
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthComp: HealthComponent = $HealthComponent
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
@onready var floorComp: FloorRotaterComponent = $FloorRotaterComponent
@onready var movement_comp: MovementComponent = $MovementComponent
@onready var abyss_checker_component: AbyssCheckerComponent = $AbyssCheckerComponent

var jump_x: int = 0
var direction: int = 1
var is_alive: bool = true

func _ready() -> void:
	animatedSprite.play("walk")
	healthComp.died.connect(die)
	resetComp.resetting_stats.connect(respawn)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	floorComp.update_rotation()
	var on_floor: bool = is_on_floor()
	
	if not on_floor:
		movement_comp.apply_gravity(delta)
	
	if on_floor:
		if animatedSprite.animation == "air":
			on_landing()
		else:
			if is_on_wall() or abyss_checker_component.is_over_abyss():
				turn()
	
	var snap_value: int = 4 if is_on_floor() else 0
	
	if not floor_snap_length == snap_value:
		floor_snap_length = snap_value
	
	movement_comp.move_horizontal(direction, false)
	move_and_slide()


func on_landing() -> void:
	animatedSprite.play("walk")
	if floor(position.x) == jump_x:
		turn()


func turn() -> void:
	direction *= -1
	animatedSprite.flip_h = not animatedSprite.flip_h
	RayCast.position.x *= -1


func die() -> void:
	is_alive = false
	animatedSprite.play("die")


func respawn() -> void:
	is_alive = true
	animatedSprite.play("walk")



func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
