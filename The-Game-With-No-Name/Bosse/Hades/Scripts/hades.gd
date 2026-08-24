extends CharacterBody2D
class_name Hades

signal fall

enum State {IDLE, WARNING, ATTACKING, STUNNED, DEAD}
enum Phase {Phase_1, Phase_2, ENRAGED}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var health_comp: HealthComponent = $healthComponent
@onready var sprite: Sprite2D = $"EndBoss(ver2)"
@onready var wave_component: Array[WaveComponent] = [$wave_component_left, $wave_component_right]
@onready var marker: Array[Marker2D] = [$MarkerLeft, $MarkerRight] 
@onready var move_comp: MovementComponent = $MovementComponent
@onready var reset_comp: EnemyResetComponent = $ResetComponent

var state: State = State.IDLE
var phase: Phase = Phase.Phase_1
var queued_attack: BossAttack
var current_attack: BossAttack

var attacks: Array[BossAttack] = []

var last_attack: BossAttack

func _ready() -> void:
	setup()
	reset_comp.enabling_stats.connect(reset_stats)
	await get_tree().create_timer(1).timeout
	start_warning()


func reset_stats() -> void:
	velocity = Vector2.ZERO
	last_attack = null
	queued_attack = null
	current_attack = null
	state = State.IDLE
	phase = Phase.Phase_1
	animation_player.play("RESET")
	G.boss_value_changed.emit(health_comp.health / health_comp.max_health * 100)
	await get_tree().create_timer(1).timeout
	start_warning()


func setup() -> void:
	move_comp.setup(self)
	G.boss_begin.emit("Hades", 100)
	health_comp.value_changed.connect(set_health_bar)
	health_comp.died.connect(died)
	
	attacks = [
		DashAttack.new(self),
		SlamAttack.new(self),
		ShockwaveAttack.new(self),
		AxtAttack.new(self)
	]


func start_warning() -> void:
	state = State.WARNING
	animation_player.play("Warning")




func set_health_bar() -> void:
	update_phase()
	G.boss_value_changed.emit(health_comp.health / health_comp.max_health * 100)
#	animation_player.play("Damage")


func choose_attack() -> void:
	if state == State.DEAD:
		return
	
	var possible: Array[BossAttack] = []
	
	for attack: BossAttack in attacks:
		if attack.can_use():
			if attack == last_attack:
				continue
			possible.append(attack)
	
	if possible.is_empty():
		possible = attacks.duplicate()
	
	current_attack = possible.pick_random()
	
	start_attack()


func queue_attack(attack: BossAttack) -> void:
	update_facing()
	queued_attack = attack


func start_attack() -> void:
	state = State.ATTACKING
	animation_player.play("RESET")
	current_attack.start()


func finish_attack() -> void:
	state = State.IDLE
	player_detector.changeTarget()
	last_attack = current_attack
	current_attack = null
	
	if queued_attack:
		current_attack = queued_attack
		queued_attack = null
		
		start_attack()
		return
	
	start_cooldown()


func start_cooldown() -> void:
	var time: float = get_cooldown()
	
	await get_tree().create_timer(time).timeout
	
	start_warning()


func get_cooldown() -> float:
	match phase:
		Phase.Phase_1:
			return randf_range(2.0, 4.0)
		Phase.Phase_2:
			return randf_range(1.0, 2.5)
		Phase.ENRAGED:
			return randf_range(0.5, 1.5)
	
	return 2.0


func update_phase() -> void:
	var hp_percent: float = health_comp.health / health_comp.max_health
	
	if hp_percent <= 0.4:
		phase = Phase.ENRAGED
	elif hp_percent <= 0.7:
		phase = Phase.Phase_2


func _physics_process(delta: float) -> void:
	if state == State.ATTACKING:
		if current_attack:
			current_attack.update(delta)
	
	move_comp.apply_normal_gravity(delta)
	
	if state == State.IDLE:
		update_facing()
		move_and_slide()


func update_facing() -> void:

	var player: Player = player_detector.focus_player

	if player == null:
		return
	
	sprite.flip_h = player.global_position.x > global_position.x


func died() -> void:
	G.boss_finished.emit()
	if Save.options.deaths[Save.active_slot] == 0:
		var achievment_comp: AchievmentComponent = $achievmentComponent
		achievment_comp.add_achievment()
	
	
	var transition_comp: LevelTransition = $LeveltransitionComponent
	transition_comp.transition()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Warning":
		choose_attack()
