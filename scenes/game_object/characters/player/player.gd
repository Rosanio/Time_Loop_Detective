extends CharacterBody2D
class_name Player

const SPEED = 80;

@onready var inventory: Inventory = $InventoryComponent
@onready var vision_calculator = $VisionCalculator
@onready var vision_viewport: Viewport = get_tree().get_root().get_node("/root/Main/VisionViewport")
@onready var vision_mask_polygon: Polygon2D = get_tree().get_root().get_node("/root/Main/VisionViewport/MaskRoot/MaskPolygon")

var interactables_in_range: Array[Interactable] = []
var closest_interactable: Interactable

func _ready():
	$PlayerInteractableArea.area_entered.connect(interactable_area_entered)
	$PlayerInteractableArea.area_exited.connect(interactable_area_exited)


func _process(_delta: float):
	process_movement()
	update_active_interactable()

	if Input.is_action_just_pressed("interact") and closest_interactable:
		closest_interactable.emit_interact(self)


func _physics_process(_delta: float):
	vision_mask_polygon.polygon = vision_calculator.calculate_vision_polygon()
	hide_objects_out_of_vision()


func interactable_area_entered(other_area: Area2D):
	var interactable = other_area.get_node("InteractableComponent") as Interactable
	interactables_in_range.append(interactable)


func interactable_area_exited(other_area: Area2D):
	var interactable = other_area.get_node("InteractableComponent") as Interactable
	interactables_in_range = interactables_in_range.filter(func(i): return i != interactable)
	interactable.set_inactive()


func process_movement():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var direction = Vector2(x_movement, y_movement).normalized()
	velocity = SPEED * direction

	move_and_slide()


func update_active_interactable():
	if interactables_in_range.size() == 0:
		closest_interactable = null
		return

	get_closest_interactable()

	var active_interactable = interactables_in_range.filter(func(i): return i.active == true)
	if active_interactable != [] and active_interactable[0] != closest_interactable:
		active_interactable[0].set_inactive()
	if closest_interactable and not closest_interactable.active:
		closest_interactable.set_active()


func get_closest_interactable():
	closest_interactable = null
	var shortest_distance = 9999
	for interactable in interactables_in_range:
		var distance = interactable.area.global_position.distance_squared_to(global_position)
		if (distance < shortest_distance):
			shortest_distance = distance
			closest_interactable = interactable


func hide_objects_out_of_vision():
	var tex = vision_viewport.get_texture()
	for obj in get_tree().get_nodes_in_group("VisionSensitive"):
		var sprite: Sprite2D = obj.get_node("Sprite2D")
		var mat := sprite.material
		if mat:
			mat.set_shader_parameter("vision_mask", tex)
