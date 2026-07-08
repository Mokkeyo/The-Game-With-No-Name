extends Node
class_name KnockbackComponent

@export var body: CharacterBody2D

func apply(hit: HitData) -> void:
	match hit.knockback_type:
		HitData.KnockbackType.NONE:
			return
		
		HitData.KnockbackType.NORMAL:
			apply_normal(hit)
		
		HitData.KnockbackType.UP:
			apply_up(hit)
		
		HitData.KnockbackType.DOWN:
			apply_down(hit)
		
		HitData.KnockbackType.EXPLOSION:
			apply_explosion(hit)
		
		HitData.KnockbackType.VERTIKAL:
			apply_vertikal(hit)


func apply_vertikal(hit: HitData) -> void:
	var dir: Vector2 = Vector2.ZERO
	dir.x = (body.global_position.x - hit.source.global_position.x)
	
	dir.y -= hit.updward_force
	dir = dir.normalized()
	
	body.velocity = dir * hit.knockback_force



func apply_normal(hit: HitData) -> void:
	var dir: Vector2 = (body.global_position - hit.source.global_position).normalized()
	
	dir.y -= hit.updward_force
	dir = dir.normalized()
	
	body.velocity = dir * hit.knockback_force


func apply_up(hit: HitData) -> void:
	body.velocity.y = -hit.knockback_force


func apply_down(hit: HitData) -> void:
	body.velocity.y = hit.knockback_force


func apply_explosion(hit: HitData) -> void:
	var distance: float = body.global_position.distance_to(hit.source.global_position)
	
	if distance > hit.radius:
		return
	
	var strength: float = 1.0 - distance / hit.radius
	
	var dir: Vector2 = body.global_position - hit.source.global_position
	dir.y -= hit.updward_force
	dir = dir.normalized()
	
	body.velocity = dir * hit.knockback_force * strength
