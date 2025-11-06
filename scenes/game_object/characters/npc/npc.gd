extends CharacterBody2D
class_name Npc

const SPEED = 90

@export var sprite_texture: Texture2D
@export var starting_items: Array[ItemData]

@onready var sprite = $Sprite2D
@onready var nav_region = $"../NavigationRegion2D"
@onready var nav_agent = $NavigationAgent2D
@onready var tile_map = $"../NavigationRegion2D/TileMap"
@onready var inventory: Inventory = $InventoryComponent
@onready var behavior_context: BehaviorContextResolver = $BehaviorContextResolver
@onready var dialog_context: DialogContextResolver = $DialogContextResolver
@onready var vision_calculator := $VisionCalculator

var astar_grid: AStarGrid2D
var nav_path: Array
var vision_enabled: bool = false
var tracked_entity: Node2D
var pathfinding_mode: PathfindingMode = PathfindingMode.FOLLOW_PATH
var current_schedule: Array

enum PathfindingMode {
	FOLLOW_PATH,
	FREEFORM
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
	check_for_tracked_entity()
	move_along_path()


func on_world_time_tick(time: TimeData):
	if not current_schedule:
		return

	for event in current_schedule:
		var event_time: TimeData = TimeData.from_dict(event["time"])
		if TimeData.is_time_equal(time, event_time):
			move_to_tile(event["coords"])


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


func set_current_schedule(schedule: Array):
	current_schedule = schedule


func check_for_tracked_entity():
	if not vision_enabled or not tracked_entity:
		return
	var vision_polygon: PackedVector2Array = vision_calculator.calculate_vision_polygon()
	var entity_screen_position = get_viewport().canvas_transform * tracked_entity.global_position
	if Geometry2D.is_point_in_polygon(entity_screen_position, vision_polygon):
		move_to_tracked_entity()
		vision_enabled = false


func move_to_tile(destination: Vector2i):
	var id_path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position),
		destination
	).slice(1)
	
	if id_path.is_empty() == false:
		nav_path = id_path


func move_to_tracked_entity():
	pathfinding_mode = PathfindingMode.FREEFORM


func move_along_path():
	if pathfinding_mode == PathfindingMode.FOLLOW_PATH:
		if nav_path.is_empty():
			return

		var target_position: Vector2 = tile_map.map_to_local(nav_path.front())
		move_towards(target_position)

		if global_position.distance_to(target_position) < 1:
			nav_path.pop_front()
	elif pathfinding_mode == PathfindingMode.FREEFORM:
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
