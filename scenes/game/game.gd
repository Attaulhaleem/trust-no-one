extends Node2D

@export_group("Aim Assist")
@export var aim_assist_enabled: bool = true
@export var aim_snap_radius: float = 80.0
@export var aim_unsnap_radius: float = 120.0
@export var aim_pull_strength: float = 15.0

var _current_snapped_stickman: Stickman = null

func _process(delta: float) -> void:
	if not aim_assist_enabled:
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	
	# 1. Check if we need to unsnap from our current target
	if _current_snapped_stickman:
		if _current_snapped_stickman.is_dead:
			_current_snapped_stickman = null
		else:
			var snapped_pos = _current_snapped_stickman.get_global_transform_with_canvas().origin
			if snapped_pos.distance_to(mouse_pos) > aim_unsnap_radius:
				_current_snapped_stickman = null
			else:
				# Track the target's movement so the cursor "sticks" to them
				var target_vel = _current_snapped_stickman.velocity
				var new_mouse_pos = mouse_pos + target_vel * delta
				
				# Pull the cursor towards the exact center for a tighter lock
				if aim_pull_strength > 0.0:
					var to_center = snapped_pos - new_mouse_pos
					new_mouse_pos += to_center * min(aim_pull_strength * delta, 1.0)
					
				if new_mouse_pos != mouse_pos:
					Input.warp_mouse(new_mouse_pos)
					mouse_pos = new_mouse_pos
					
	# 2. If we aren't snapped, look for a new target to snap to
	if not _current_snapped_stickman:
		var closest_dist = INF
		var closest_stickman: Stickman = null
		
		for node in get_tree().get_nodes_in_group("stickman"):
			var child := node as Stickman
			if child and not child.is_dead and child.visible:
				var target_pos = child.get_global_transform_with_canvas().origin
				var dist = target_pos.distance_to(mouse_pos)
				if dist < closest_dist:
					closest_dist = dist
					closest_stickman = child
					
		if closest_stickman and closest_dist < aim_snap_radius:
			var target_pos = closest_stickman.get_global_transform_with_canvas().origin
			Input.warp_mouse(target_pos)
			_current_snapped_stickman = closest_stickman
