extends Node2D

var vision_radius: float = 500.0
var ray_count: int = 512
var collision_mask: int = 8

# Adaptive refinement
var refinement_distance_threshold: float = 8.0
var max_refinement_depth: int = 2

@onready var mask_polygon: Polygon2D = get_tree().get_root().get_node("/root/Main/VisionViewport/MaskRoot/MaskPolygon")

func _physics_process(_delta: float):
	var space_state = get_world_2d().direct_space_state

	var angles: Array = []
	var step = TAU / ray_count
	for i in range(ray_count):
		angles.append(step * i)

	var points: Array = []
	cast_rays_recursive(space_state, angles, 0, points)

	points.sort_custom(func(a, b): return a.angle < b.angle)
	var safe_points: Array = []
	var min_distance = 0.1
	for point in points:
		if safe_points.size() == 0 or safe_points[-1].position.distance_to(point.position) > min_distance:
			safe_points.append(point)

	if mask_polygon:
		var screen_points := PackedVector2Array()
		var canvas_transform = get_viewport().get_canvas_transform()
		for global_point in safe_points:
			screen_points.append(canvas_transform * global_point.position)
		mask_polygon.polygon = screen_points


func cast_rays_recursive(state_space, angles: Array, depth: int, out_points: Array):
	if depth > max_refinement_depth:
		return

	var hits = []
	for angle in angles:
		var direction = Vector2(cos(angle), sin(angle))
		var hit = state_space.intersect_ray(
			PhysicsRayQueryParameters2D.create(
				global_position,
				global_position + direction * vision_radius,
				collision_mask,
				[get_parent()]
			)
		)
		if hit:
			hits.append({ "angle": angle, "position": hit.position, "distance": global_position.distance_to(hit.position) })
		else:
			hits.append({ "angle": angle, "position": global_position + direction * vision_radius, "distance": vision_radius })

	hits.sort_custom(func(a, b): return a.angle < b.angle)

	for i in range(hits.size()):
		var cur = hits[i]
		var next = hits[(i + 1) % hits.size()]
		out_points.append(cur)

		var dist_diff = abs(cur.distance - next.distance)
		if dist_diff > refinement_distance_threshold:
			var mid_angle = (cur.angle + next.angle) * 0.5
			var lower_mid_angle = (mid_angle + cur.angle) * 0.5
			var upper_mid_angle = (mid_angle + next.angle) * 0.5
			cast_rays_recursive(state_space, [lower_mid_angle, mid_angle, upper_mid_angle], depth + 1, out_points)
