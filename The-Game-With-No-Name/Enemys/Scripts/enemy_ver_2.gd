extends CharacterBody2D
class_name EnemyVer2

@onready var RayCast: RayCast2D = $RayCast
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthComp: HealthComponent = $HealthComponent
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
@onready var floorComp: FloorRotaterComponent = $FloorRotaterComponent
@onready var movement_comp: MovementComponent = $MovementComponent
@onready var abyss_checker_component: AbyssCheckerComponent = $AbyssCheckerComponent

enum State {DEAD, ON_FLOOR, IN_AIR}
var state: State = State.ON_FLOOR

var jump_x: int = 0
var direction: int = 1


func _ready() -> void:
	floor_snap_length = 8
	animatedSprite.play("walk")
	healthComp.died.connect(die)
	resetComp.enabling_stats.connect(respawn)

func _physics_process(delta: float) -> void:
	match state:
		State.DEAD:
			return
	
		State.ON_FLOOR:
			if not is_on_floor():
				state = State.IN_AIR
				return
			
			floorComp.update_rotation()
			
			check_for_abyss()
		
		State.IN_AIR:
			if is_on_floor():
				state = State.ON_FLOOR
				on_landing()
				return
			
			movement_comp.apply_gravity(delta)
	
	movement_comp.move_horizontal(direction, false)
	move_and_slide()


func on_landing() -> void:
	animatedSprite.play("walk")
	RayCast.enabled = true


func check_for_abyss() -> void:
	if is_on_wall() or abyss_checker_component.is_over_abyss():
		turn()

func turn() -> void:
	direction *= -1
	animatedSprite.flip_h = not animatedSprite.flip_h
	RayCast.position.x *= -1


func die() -> void:
	state = State.DEAD
	animatedSprite.play("die")


func respawn() -> void:
	state = State.ON_FLOOR
	animatedSprite.play("walk")



func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.disable_stats()
