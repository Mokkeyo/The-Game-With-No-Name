extends Node
class_name MenuNavigator

var is_transitioning: bool = false
var current_menu: Menu

enum Mode {
	CAMERA,
	UI
}

var mode: Mode = Mode.CAMERA

func change_menu(owner_n: Node, target_menu: Menu, focus_node: Control) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	target_menu.visible = true
	match mode:
		Mode.CAMERA:
			await tween_node2d(owner_n, target_menu)
		Mode.UI:
			await tween_control(owner_n, target_menu)
	
	current_menu = target_menu
	target_menu.enter()
	
	if focus_node:
		focus_node.grab_focus()
	
	is_transitioning = false


func to_start_menu(owner_n: Node, start_node: Control, old_menu: Menu, focus_node: Control) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	match mode:
		Mode.CAMERA:
			await tween_node2d(owner_n, start_node)
		Mode.UI:
			await tween_control(owner_n, start_node)
	
	
	old_menu.visible = false
	current_menu = null
	
	if focus_node:
		focus_node.grab_focus()
	
	is_transitioning = false

func tween_control(from: Control, to: Control) -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(from, "global_position", Vector2.ZERO, 0.4)
	tween.tween_property(to, "global_position", -from.global_position, 0.4)
	await tween.finished

func tween_node2d(from: Node2D, to: Control) -> void:
	var tween: Tween = from.create_tween()
	
	match mode:
		Mode.CAMERA:
			tween.tween_property(from, "global_position", to.global_position, 0.4)
		
		Mode.UI:
			tween.set_parallel(true)
			tween.tween_property(from, "global_position", Vector2.ZERO, 0.4)
			tween.tween_property(to, "global_position", -from.global_position, 0.4)

	await  tween.finished
