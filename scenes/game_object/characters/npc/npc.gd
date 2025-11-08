extends CharacterBody2D
class_name Npc

const SPEED = 90

@export var sprite_texture: Texture2D
@export var starting_items: Array[ItemData]

@onready var sprite = $Sprite2D
@onready var nav_region = $"/root/Main/NavigationRegion2D"
@onready var nav_agent = $NavigationAgent2D
@onready var tile_map: TileMapLayer = $"/root/Main/NavigationRegion2D/TileMap"
@onready var inventory: Inventory = $InventoryComponent
@onready var behavior_context: BehaviorContextResolver = $BehaviorContextResolver
@onready var dialog_context: DialogContextResolver = $DialogContextResolver
@onready var vision_calculator := $VisionCalculator

var astar_grid: AStarGrid2D
var nav_path: Array
var vision_enabled: bool = false
var tracked_entity: Node2D
var pathfinding_mode: PathfindingMode = PathfindingMode.ASTAR
var current_schedule: Array
var dialog_on_player_interact: String
var desired_item_ids: Array[String] = []
var sought_entities: Array[Node2D] = []

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
	$InteractableDetectionArea.area_entered.connect(interactable_area_entered)

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
	if not vision_enabled:
		return

	for item_id in desired_item_ids:
		var item = ItemsRegistry.get_item(item_id)
		if item != null:
			sought_entities.push_front(item)
	if sought_entities.size() == 0:
		return

	var vision_polygon: PackedVector2Array = vision_calculator.calculate_vision_polygon()
	for entity in sought_entities:
		var entity_screen_position = get_viewport().canvas_transform * entity.global_position
		if Geometry2D.is_point_in_polygon(entity_screen_position, vision_polygon):
			tracked_entity = entity
			pathfinding_mode = PathfindingMode.NAVMESH
			vision_enabled = false
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
		tracked_entity = null
		pathfinding_mode = PathfindingMode.NONE
		load_dialog(dialog_on_player_interact)
		dialog_on_player_interact = ""


func handle_item_interact(item: Item):
	if not tracked_entity: return

	var tracked_item = tracked_entity.get_node_or_null("ItemComponent") as Item
	if tracked_item and tracked_item.item_data.id == item.item_data.id:
		tracked_entity = null
		pathfinding_mode = PathfindingMode.NONE
		behavior_context.handle_item_found(item)


func load_dialog(dialog_key: String):
	dialog_context.load_dialog_from_json(dialog_key)


func return_to_path():
	nav_agent.target_position = find_nearest_path_tile()
	pathfinding_mode = PathfindingMode.NAVMESH
	await nav_agent.navigation_finished


func find_nearest_path_tile():
	var best_tile = null
	var min_distance = 9999
	var current_tile = tile_map.local_to_map(global_position)
	var tile_data = tile_map.get_cell_tile_data(current_tile)
	if tile_data.get_custom_data("walkable"): return current_tile
	for x in range(current_tile.x - 3, current_tile.x + 4):
		for y in range(current_tile.y - 3, current_tile.y + 4):
			tile_data = tile_map.get_cell_tile_data(Vector2(x, y))
			if tile_data.get_custom_data("walkable"):
				var tile_global_position = tile_map.map_to_local(Vector2(x, y))
				var distance = global_position.distance_to(tile_global_position)
				if distance < min_distance:
					min_distance = distance
					best_tile = Vector2(x, y)
	if not best_tile:
		printerr("Closest path tile in range of 5 not found")
	return tile_map.map_to_local(best_tile)


func resume_schedule():
	if not current_schedule:
		printerr("No schedule loaded")

	for i in range(0, current_schedule.size() - 1):
		var current_event = current_schedule[i]
		if i == current_schedule.size() + 1:
			follow_path_to_tile(current_event["coords"])
			break

		var current_time = TimeData.from_dict(current_event["time"])
		var next_time = TimeData.from_dict(current_schedule[i + 1]["time"])
		if WorldTimeManager.get_current_time().is_in_range(current_time, next_time):
			follow_path_to_tile(current_event["coords"])
			break
