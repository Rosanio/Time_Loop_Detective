extends Area2D

const SPEED = 0.5
const SCHEDULE = [
	{
		"time": {
			"hour": 9,
			"minute": 0,
			"am_pm": "AM"
		},
		"coords": Vector2i(51, 26)
	},
	{
		"time": {
			"hour": 0,
			"minute": 3,
			"am_pm": "PM"
		},
		"coords": Vector2i(248, 407)
	}
]

@export var dialog_context: DialogContextResolver
@export var sprite_texture: Texture2D

@onready var sprite = $Sprite2D
@onready var tile_map = $"../TileMap"
@onready var world_time_manager: Node = $"../WorldTimeManager"

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = sprite_texture
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
	
	world_time_manager.on_tick.connect(on_world_time_tick)
	($InteractableComponent as Interactable).interact.connect(on_interact)


func _process(_delta):
	if current_id_path.is_empty():
		return
		
	var target_position = tile_map.map_to_local((current_id_path.front()))
	global_position = global_position.move_toward(target_position, SPEED)
	
	if global_position == target_position:
		current_id_path.pop_front()


func on_interact():
	dialog_context.GetDialogForCurrentContext()


func on_world_time_tick(time):
	for event in SCHEDULE:
		if is_time_equal(time, event["time"]):
			move_to(event["coords"])


func is_time_equal(time1, time2):
	return time1["hour"] == time2["hour"] && time1["minute"] == time2["minute"] && time1["am_pm"] == time2["am_pm"]


func move_to(destination: Vector2i):
	var id_path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(destination)
	).slice(1)
	
	if id_path.is_empty() == false:
		current_id_path = id_path
