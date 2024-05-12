extends Node

@export var player: CharacterBody2D

var interactables_in_range: Array[Interactable] = []

func _ready():
	GameEvents.interactable_area_entered.connect(on_interactable_entered)
	GameEvents.interactable_area_exited.connect(on_interactable_left)


func _process(_delta):
	if interactables_in_range.size() == 0:
		return
	
	var closest_interactable = get_closest_interactable()
	
	var active_interactable = interactables_in_range.filter(func(i): return i.active == true)
	if active_interactable != []:
		active_interactable[0].set_inactive()
	closest_interactable.set_active()
	
	if Input.is_action_just_pressed("interact"):
		closest_interactable.emit_interact()


func on_interactable_entered(interactable: Interactable):
	interactables_in_range.append(interactable)


func on_interactable_left(interactable: Interactable):
	interactables_in_range = interactables_in_range.filter(func(i): return i != interactable)
	interactable.set_inactive()


func get_closest_interactable():
	var closest_interactable: Interactable = null
	var shortest_distance = 9999
	for interactable in interactables_in_range:
		var distance = interactable.area.global_position.distance_squared_to(player.global_position)
		if (distance < shortest_distance):
			shortest_distance = distance
			closest_interactable = interactable
	return closest_interactable
