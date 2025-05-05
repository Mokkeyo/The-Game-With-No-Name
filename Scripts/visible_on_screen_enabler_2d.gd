extends VisibleOnScreenNotifier2D

@export var node: Node2D
@export var set_processmode: bool = false
@export var set_visibility: bool = false
@export var set_animation_player: bool = false
@export var set_animated_sprite: bool = false
@export var sprites: Array[Node2D]

func _ready() -> void:
	if not node:
		node = get_parent()
	stop_all()


func _on_screen_entered() -> void:
	if set_processmode:
		node.process_mode = Node.PROCESS_MODE_INHERIT
	if set_visibility:
		show_sprite(true)
	if set_animation_player:
		check_for_animationplayer(node, false)
	if set_animated_sprite:
		check_for_animated_sprite(node, false)


func _on_screen_exited() -> void:
	stop_all()


func stop_all() -> void:
	if set_processmode:
		node.process_mode = PROCESS_MODE_DISABLED
	if set_visibility:
		show_sprite(false)
	if set_animation_player:
		check_for_animationplayer(node, true)
	if set_animated_sprite:
		check_for_animated_sprite(node, true)


func show_sprite(make_visible: bool) -> void:
	if sprites.size() > 0:
		for node2D: Node2D in sprites:
			if not node2D == self:
				node2D.visible = make_visible
	else:
		node.visible = make_visible


func check_for_animationplayer(node2D: Node2D, pause: bool) -> void:
	for child: Node in node2D.get_children():
		var player: AnimationPlayer
		if child is AnimationPlayer:
			player = child
		elif not child.get_child_count() == 0:
			for sub_child: Node in child.get_children():
				if sub_child is AnimationPlayer:
					player = sub_child
		if player:
			if pause:
				player.set_meta("current_animation", player.current_animation)
				player.stop()
			else:
				if player.has_meta("current_animation"):
					var anim_name: String = player.get_meta("current_animation")
					if not anim_name == "":
						player.play(anim_name)


func check_for_animated_sprite(node2D: Node2D, pause: bool) -> void:
	for child: Node in node2D.get_children():
		var player: AnimatedSprite2D
		if child is AnimatedSprite2D:
			player = child
		elif not child.get_child_count() == 0:
			for sub_child: Node in child.get_children():
				if sub_child is AnimatedSprite2D:
					player = sub_child
		if player:
			if pause:
				if player.is_playing():
					player.stop()
			else:
				player.play()
