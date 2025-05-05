extends Node2D

@onready var boss: Boss = $Boss
@onready var armRight: bossArm = $"BossArm(right)"
@onready var armLeft: bossArm = $"BossArm(left)"
@onready var airshipDetector: AirshipDetector = $airshipDetector
@onready var waitTimer: Timer = $shoot_cooldown
@onready var laser_cooldown: Timer = $laser_cooldown
@onready var laser_duration: Timer = $laser_duration

var alive: int = 3
var activated: bool = false
var shooting_laser: bool = false

func _ready() -> void:
	armLeft.healthComp.died.connect(part_died)
	armRight.healthComp.died.connect(part_died)
	boss.healthComp.died.connect(part_died)
	armLeft.healthComp.value_changed.connect(change_arm_health)
	armRight.healthComp.value_changed.connect(change_arm_health)
	G.bossLabel = "Arm Bottom + Arm Top"
	change_arm_health()
	set_process(false)


func shoot() -> void:
	if armLeft.is_alive:
		armLeft.shootComp.shoot_bullet()
	if armRight.is_alive:
		armRight.shootComp.shoot_bullet()
	airshipDetector.changeTarget()


func rotate_parts(delta: float, focused_airship: Airship) -> void:
	if boss.is_alive:
		boss.process(delta, focused_airship)
	if armLeft.is_alive:
		armLeft.process(delta, focused_airship)
	if armRight.is_alive:
		armRight.process(delta, focused_airship)


func part_died() -> void:
	alive -= 1 
	if alive == 2:
		waitTimer.wait_time = 1.5
		return
	
	if alive == 1:
		boss.hurtbox_collision.set_deferred("disabled", false)
		boss.healthComp.value_changed.connect(change_boss_health)
		G.bossLabel = "Galaga"
		G.maxBossHp = boss.healthComp.max_health
		G.emit_signal("boss_label_changed")
		G.emit_signal("boss_value_changed")
		change_boss_health()
		return
		
	G.emit_signal("boss_finished")


func _process(delta: float) -> void:
	if alive == 0:
		set_process(false)
		return
	
	if waitTimer.is_stopped():
		shoot()
		waitTimer.start()
		
	if airshipDetector.focus_player:
		rotate_parts(delta, airshipDetector.focus_player)
	
	if alive > 1:
		return
	
	if laser_cooldown.is_stopped():
		laser_duration.start()
		laser_cooldown.start()
		return

	if laser_duration.is_stopped():
		if waitTimer.is_stopped():
			boss_shoot()
			waitTimer.start()
	else:
		if laser_duration.time_left > 3:
			boss.Warning()
		else:
			boss.Laser()


func boss_shoot() -> void:
	if boss.is_alive and alive == 1:
		boss.shootComp[0].shoot_bullet()
		boss.shootComp[1].shoot_bullet()


func change_arm_health() -> void: 
	G.bossHp = float(armLeft.healthComp.health + armRight.healthComp.health)
	G.emit_signal("boss_value_changed")


func change_boss_health() -> void:
	G.bossHp = boss.healthComp.health
	G.emit_signal("boss_value_changed")


func _on_airship_detector_body_entered(body: Node2D) -> void:
	if activated:
		return
		
	if body.is_in_group("airship"):
		G.maxBossHp = float(armLeft.healthComp.max_health + armRight.healthComp.max_health)
		G.emit_signal("boss_begin")
		set_process(true)
		activated = true
