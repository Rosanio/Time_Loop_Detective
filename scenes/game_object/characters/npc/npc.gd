extends CharacterBody2D
class_name Npc

signal tracked_entity_reached(tracked_entity: Node2D)

const SPEED = 90

@export var npc_name: String
@export var sprite_texture: Texture2D
@export var starting_items: Array[ItemData]

@onready var sprite = $Sprite2D
@onready var nav_region = $"/root/Main/NavigationRegion2D"
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var tile_map: TileMapLayer = $"/root/Main/NavigationRegion2D/TileMap"
@onready var inventory: Inventory = $InventoryComponent
@onready var behavior_context: BehaviorContextResolver = $BehaviorContextResolver
@onready var dialog_context: DialogContextResolver = $DialogContextResolver
@onready var vision_calculator := $VisionCalculator
@onready var npc_container := $"/root/Main/Npcs"
@onready var player: Player = $"/root/Main/Player"
@onready var interactable_detection_area: Area2D = $InteractableDetectionArea

var astar_grid: AStarGrid2D
var nav_path: Array
var tracked_entity: Node2D
var pathfinding_mode: PathfindingMode = PathfindingMode.ASTAR
var current_schedule_key: String
var current_schedule: Array
var dialog_on_player_interact: String
var desired_item_ids: Array[String] = []
var sought_entities: Array[Node2D] = []
var seek_id = 0

enum PathfindingMode {
	ASTAR,
	NAVMESH,
	NONE
}

func _ready():
	sprite.texture = sprite_texture
	initialize_pathfinding()
	behavior_context.run_initial_behavior()

	WorldTimeManager.on_tick.connect(on_world_time_tick)
	($InteractableDetectionArea/InteractableComponent as Interactable).interact.connect(on_interact)
	interactable_detection_area.area_entered.connect(interactable_area_entered)
	GameEvents.player_dropped_item.connect(player_dropped_item)
	GameEvents.player_picked_up_item.connect(player_picked_up_item)

	for item in starting_items:
		$InventoryComponent.inventory.append(item)


func _physics_process(_delta: float):
	check_for_sought_entities()
	move_along_path()


func on_world_time_tick(time: TimeData):
	if not current_schedule:
		return

	for event in current_schedule:
		var event_time: TimeData = TimeData.from_dict(event["time"])
		if TimeData.is_time_equal(time, event_time):
			follow_path_to_tile(event["coords"])


func on_interact(interactor: Node):
	if interactor is Player:
		dialog_context.get_dialog_for_current_context()
	elif interactor is Npc:
		if tracked_entity and tracked_entity is Npc and tracked_entity.npc_name == interactor.npc_name:
			emit_tracked_entity_reached(tracked_entity)


func interactable_area_entered(other_area: Area2D):
	var interactable: Interactable = other_area.get_node("InteractableComponent")
	interactable.emit_interact(self)


func initialize_pathfinding():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2i(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)

			var tile_data = tile_map.get_cell_tile_data(tile_position)

			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)

	nav_agent.set_navigation_map(nav_region.get_navigation_map())


func check_for_sought_entities():
	if sought_entities.size() == 0:
		return

	var vision_polygon: PackedVector2Array = vision_calculator.calculate_vision_polygon()
	for entity in sought_entities:
		var entity_screen_position = get_viewport().canvas_transform * entity.global_position
		if Geometry2D.is_point_in_polygon(entity_screen_position, vision_polygon):
			tracked_entity = entity
			pathfinding_mode = PathfindingMode.NAVMESH
			break


func follow_path_to_tile(destination: Vector2i):
	pathfinding_mode = PathfindingMode.ASTAR
	var id_path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position),
		destination
	).slice(1)

	if id_path.is_empty() == false:
		nav_path = id_path


func move_along_path():
	if pathfinding_mode == PathfindingMode.ASTAR:
		if nav_path.is_empty():
			return

		var target_position: Vector2 = tile_map.map_to_local(nav_path.front())
		move_towards(target_position)

		if global_position.distance_to(target_position) < 1:
			nav_path.pop_front()
	elif pathfinding_mode == PathfindingMode.NAVMESH:
		if tracked_entity:
			nav_agent.target_position = tracked_entity.global_position

		if not nav_agent.is_navigation_finished():
			var next_point: Vector2 = nav_agent.get_next_path_position()
			move_towards(next_point)


func move_towards(target: Vector2):
	var direction = (target - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()


func handle_missing_key(door: Door):
	if current_schedule:
		nav_path.clear()
		current_schedule.clear()
		behavior_context.handle_missing_key(door)


func handle_player_interact():
	if tracked_entity is Player:
		var entity_clone = tracked_entity
		sought_entities.erase(tracked_entity)
		tracked_entity = null
		pathfinding_mode = PathfindingMode.NONE
		emit_tracked_entity_reached(entity_clone)


func handle_item_interact(item: Item):
	if not tracked_entity or tracked_entity is not Item: return

	if tracked_entity and tracked_entity.item_data.id == item.item_data.id:
		var entity_clone = tracked_entity
		desired_item_ids.erase(tracked_entity.item_data.id)
		sought_entities.erase(tracked_entity)
		tracked_entity = null
		pathfinding_mode = PathfindingMode.NONE
		emit_tracked_entity_reached(entity_clone)


func load_dialog(dialog_key: String):
	dialog_context.load_dialog_from_json(dialog_key)


func return_to_path():
	tracked_entity = null
	nav_agent.target_position = find_nearest_path_tile()
	pathfinding_mode = PathfindingMode.NAVMESH
	await nav_agent.navigation_finished


func find_nearest_path_tile():
	var current_tile = tile_map.local_to_map(global_position)
	var current_tile_data = tile_map.get_cell_tile_data(current_tile)
	if current_tile_data.get_custom_data("path"): return tile_map.map_to_local(current_tile)

	var best_tile = null
	var min_distance := INF
	var check_radius := 1
	while not best_tile:
		for offset in range(-check_radius, check_radius + 1):
			var candidate_tiles = [
				Vector2i(current_tile.x + offset, current_tile.y - check_radius),
				Vector2i(current_tile.x + offset, current_tile.y + check_radius),
				Vector2i(current_tile.x - check_radius, current_tile.y + offset),
				Vector2i(current_tile.x + check_radius, current_tile.y + offset),
			]
			for tile in candidate_tiles:
				var tile_data = tile_map.get_cell_tile_data(tile)
				if not tile_data or not tile_data.get_custom_data("path"):
					continue
				var tile_world_position = tile_map.map_to_local(tile)
				var distance = global_position.distance_to(tile_world_position)
				if distance < min_distance:
					min_distance = distance
					best_tile = tile
		check_radius += 1
	return tile_map.map_to_local(best_tile)


func resume_schedule():
	if not current_schedule:
		printerr("No schedule loaded")

	for i in range(current_schedule.size()):
		var current_event = current_schedule[i]
		if i + 1 == current_schedule.size():
			follow_path_to_tile(current_event["coords"])
			break

		var current_time = TimeData.from_dict(current_event["time"])
		var next_time = TimeData.from_dict(current_schedule[i + 1]["time"])
		if WorldTimeManager.get_current_time().is_in_range(current_time, next_time):
			follow_path_to_tile(current_event["coords"])
			break

	# If the player resumes their schedule while already inside a door's interactable hitbox, the
	# door's interact trigger won't fire and it won't appear to open. Check if the NPC is already
	# overlapping the door and trigger it's interact logic if so.
	var overlapping_areas = interactable_detection_area.get_overlapping_areas()
	for area in overlapping_areas:
		if area.owner is Door:
			area.owner.on_interact(self)


func move_to_npc(other_npc_name: String):
	for npc in npc_container.get_children():
		if npc.npc_name == other_npc_name:
			tracked_entity = npc
			pathfinding_mode = PathfindingMode.NAVMESH


func emit_tracked_entity_reached(entity: Node2D):
	tracked_entity_reached.emit(entity)


func seek_entities(include_player: bool, items: Array = []):
	seek_id += 1
	for item_id in items:
		var item = ItemsRegistry.get_item(item_id)
		if item != null:
			sought_entities.push_front(item)
		desired_item_ids.append(item_id)

	if include_player:
		sought_entities.append(player)

	# If the NPC interactable area already overlaps with the sought entity, the interact event won't
	# trigger. Doing a check now makes sure the flow continues in this case.
	var overlapping_areas = interactable_detection_area.get_overlapping_areas()
	for entity in sought_entities:
		var interactable: Interactable = entity.find_child("InteractableComponent")
		if interactable.area in overlapping_areas:
			tracked_entity = entity
			if entity is Player:
				# Defer call in case tracked_entity_reached is being awaited by the caller
				call_deferred("handle_player_interact")
			elif entity is Item:
				call_deferred("handle_item_interact", entity)
			break


func stop_tracking(entity: Node2D):
	sought_entities.erase(entity)


func player_dropped_item(item: Item):
	if desired_item_ids.size() == 0:
		return

	for sought_item in desired_item_ids:
		if sought_item == item.item_data.id:
			if is_item_in_vision(item):
				behavior_context.sought_item_dropped_in_vision(item)
			else:
				sought_entities.append(item)


func player_picked_up_item(item: Item):
	if desired_item_ids.size() == 0:
		return

	if sought_entities.has(item):
		sought_entities.erase(item)

	for desired_item in desired_item_ids:
		if desired_item == item.item_data.id and is_item_in_vision(item):
			behavior_context.sought_item_picked_up_in_vision(item)


func is_item_in_vision(item: Item):
	var vision_polygon: PackedVector2Array = vision_calculator.calculate_vision_polygon()
	var location_screen_position = get_viewport().canvas_transform * item.global_position
	return Geometry2D.is_point_in_polygon(location_screen_position, vision_polygon)


func override_tracked_entity(entity: Node2D):
	seek_id += 1
	sought_entities.clear()
	tracked_entity = entity
	pathfinding_mode = PathfindingMode.NAVMESH
