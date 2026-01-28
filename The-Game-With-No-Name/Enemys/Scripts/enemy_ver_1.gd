extends CharacterBody2D
class_name EnemyRobot

@onready var healthComp: HealthComponent = $HealthComponent
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hpBar: progressBar = $"HPbar(enemy)"
@onready var RayCast: RayCast2D = $RayCast
@onready var resetComp: EnemyResetComponent = $EnemyResetComponent
@onready var floorComp: FloorRotaterComponent = $FloorRotaterComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var lava_water_detector: LavaWaterDetector = $LavaWater_Detector
@onready var abyss_checker_component: AbyssCheckerComponent = $AbyssCheckerComponent

@export var health: float = 40

var is_alive: bool = true
var jump_position: float
var direction: int = 1

func _ready() -> void:
	animatedSprite.play("walk")
	healthComp.died.connect(die)
	healthComp.health = health
	healthComp.max_health = health
	resetComp.resetting_stats.connect(respawn)
	movement.setup(self, lava_water_detector)


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	var on_floor: bool = is_on_floor()
	
	floorComp.update_rotation()
	if not on_floor:
		movement.apply_gravity(delta)
	else:
		if animatedSprite.animation == "air":
			on_landing()
		else:
			if is_on_wall() or abyss_checker_component.is_over_abyss():
				animatedSprite.play("air")
				jump_position = floor(position.x)
				movement.jump()
	
	var snap_value: int = 4 if on_floor else 0
	
	if not floor_snap_length == snap_value:
		floor_snap_length = snap_value
	
	movement.move_horizontal(direction, false)
	move_and_slide()


func die() -> void:
	is_alive = false
	animatedSprite.play("die")


func on_landing() -> void:
	animatedSprite.play("walk")
	if floor(position.x) == jump_position:
		turn()


func turn() -> void:
	direction *= -1
	animatedSprite.flip_h = not animatedSprite.flip_h
	RayCast.position.x *= -1


func respawn() -> void:
	is_alive = true
	animatedSprite.play("walk")


func _on_AnimatedSprite_animation_finished() -> void:
	if animatedSprite.animation == "die":
		resetComp.set_stats()
