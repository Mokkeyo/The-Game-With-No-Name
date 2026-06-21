extends Node2D
class_name Galaga

@onready var lasers: Array[Laser] = [$laser, $laser2]
@onready var warnings: Array[Warning] = [$warning, $warning2]

@onready var galaga_head: GalagaHead = $Boss
@onready var galaga_right: GalagaArm = $"BossArm(right)"
@onready var galaga_left: GalagaArm = $"BossArm(left)"
@onready var airshipDetector: AirshipDetector = $airshipDetector
@onready var waitTimer: Timer = $shoot_cooldown
@onready var laser_cooldown: Timer = $laser_cooldown
@onready var laser_duration: Timer = $laser_duration
@onready var shoot_comp: ShootComponent = $ShootComponent
@onready var reset_comp: EnemyResetComponent = $ResetComponent

var target_switch_timer: float = 0
var alive: int = 3
var activated: bool = false
var shooting_laser: bool = false

enum HeadState {
	LASER,
	WARNING,
	SHOOTING
}

var head_state: HeadState = HeadState.SHOOTING

enum Phase {
	ARMS,
	ONE_ARM,
	CORE,
	ENRAGED
}

var phase: Phase = Phase.ARMS

func _ready() -> void:
<<<<<<< HEAD
	reset_comp.enabling_stats.connect(resetting_boss)
	galaga_head.lasers = lasers
	galaga_head.warnings = warnings
	
=======
>>>>>>> parent of 7d83985 (fixed the galaga bosses laser)
	set_physics_process(false)
	galaga_left.health_comp.died.connect(part_died)
	galaga_right.health_comp.died.connect(part_died)
	galaga_head.health_comp.died.connect(part_died)
	galaga_left.health_comp.value_changed.connect(change_arm_health)
	galaga_right.health_comp.value_changed.connect(change_arm_health)
	change_arm_health()


func resetting_boss() -> void:
	galaga_head.health_comp.health = galaga_head.health_comp.max_health
	galaga_head.is_alive = true
	
	for arm: GalagaArm in [galaga_left, galaga_right]:
		arm.health_comp.health = arm.health_comp.max_health
		arm.is_alive = true
	
	for i: int in lasers.size():
		lasers[i].stop_laser()
		warnings[i].stop_warning()
	
	alive = 3
	G.boss_finished.emit()
	
	set_physics_process(false)
	activated = false
	shooting_laser = false
	phase = Phase.ARMS
	head_state = HeadState.SHOOTING
	target_switch_timer = 0

func update_phase() -> void:
	match alive:
		3:
			phase = Phase.ARMS
		2:
			phase = Phase.ONE_ARM
		1:
			phase = Phase.CORE
	
	if not phase == Phase.CORE:
		return
	
	if galaga_head.health_comp.health <= galaga_head.health_comp.max_health * 0.3:
		phase = Phase.ENRAGED


func part_died() -> void:
	alive -= 1
	
	update_phase()
	
	match phase:
		Phase.ONE_ARM:
			waitTimer.wait_time = 1.5
		
		Phase.CORE:
			galaga_head.hurtbox_collision.set_deferred("disabled",false)
			
			galaga_head.health_comp.value_changed.connect(change_boss_health)
			
			G.boss_label_changed.emit("Galaga")
			change_boss_health()
		
		Phase.ENRAGED:
			waitTimer.wait_time = 0.5


func _physics_process(delta: float) -> void:
	if alive <= 0:
		G.boss_finished.emit()
		return
	
	target_switch_timer -= delta
	
	if target_switch_timer <= 0:
		target_switch_timer = 3
		airshipDetector.changeTarget()
	
	var target: Airship = airshipDetector.focus_player
	
	if target:
		rotate_parts(delta, target)
	
	match phase:
		Phase.ARMS:
			process_arm_phase()
		
		Phase.ONE_ARM:
			process_one_arm_phase()
		
		Phase.CORE:
			process_core_phase()
		
		Phase.ENRAGED:
			process_enraged_phase()


func process_arm_phase() -> void:
	if waitTimer.is_stopped():
		shoot()
		waitTimer.start(3)


func process_one_arm_phase() -> void:
	if waitTimer.is_stopped():
		shoot()
		waitTimer.start(1.5)


func process_core_phase() -> void:
	match head_state:
		
		HeadState.SHOOTING:
			if not laser_cooldown.is_stopped():
				if not waitTimer.is_stopped():
					return
				push_warning("shooting bullet")
				boss_shoot()
				waitTimer.start()
				return
			
			head_state = HeadState.WARNING
			push_warning("starting warning")
			galaga_head.start_warning()
			laser_cooldown.start()
			laser_duration.start()
	
		HeadState.WARNING:
			if laser_duration.time_left > 3.0:
				return
			
			head_state = HeadState.LASER
			push_warning("starting laser and stopping warning")
			galaga_head.stop_warning()
			galaga_head.start_laser()
	
		HeadState.LASER:
			if not laser_duration.is_stopped():
				return
			
			head_state = HeadState.SHOOTING
			push_warning("stopping laser")
			galaga_head.stop_laser()


func process_enraged_phase() -> void:
	pass
#	if waitTimer.is_stopped():
#		boss_shoot()

#		galaga_head.shoot_comp[0].shoot_bullet()
#		galaga_head.shoot_comp[1].shoot_bullet()

#		waitTimer.start(0.4)

#	if laser_cooldown.is_stopped():
#		laser_duration.start(2.0)
#		laser_cooldown.start(5.0)

#	if not laser_duration.is_stopped():
#		galaga_head.Laser()


func shoot() -> void:
	for arm: GalagaArm in [galaga_left, galaga_right]:
		if arm.is_alive:
			shoot_comp.shoot_bullet(arm, arm.marker)


func rotate_parts(delta: float, focused_airship: Airship) -> void:
	if galaga_head.is_alive and laser_duration.is_stopped():
		rotate_part(delta, focused_airship, galaga_head)
	
	for arm: GalagaArm in [galaga_left, galaga_right]:
		if arm.is_alive:
			rotate_part(delta, focused_airship, arm)


func rotate_part(d: float, a: Airship, g: Node2D) -> void:
	var direction: Vector2 = (a.global_position - g.global_position)
	var angleTo: float = g.transform.x.angle_to(direction)
	var value: float = sign(angleTo) * min(d * 5, abs(angleTo))
	g.rotate(value)


func boss_shoot() -> void:
	if galaga_head.is_alive:
		for marker: Marker2D in galaga_head.bullet_markers:
			shoot_comp.shoot_bullet(galaga_head, marker)

func change_arm_health() -> void:
	G.boss_value_changed.emit(get_arm_health_percent())


func get_arm_health_percent() -> float:
	var current: float = 0
	var maximum: float = 0
	
	for arm: GalagaArm in [galaga_left, galaga_right]:
		current += arm.health_comp.health
		maximum += arm.health_comp.max_health
	
	return current / maximum * 100


func change_boss_health() -> void:
	G.boss_value_changed.emit(galaga_head.health_comp.health / galaga_head.health_comp.max_health * 100)


func _on_airship_detector_body_entered(body: Node2D) -> void:
	if activated:
		return
		
	if body.is_in_group("airship"):
		G.boss_begin.emit("Arm Bottom + Arm Top", 100)
		set_physics_process(true)
		activated = true
