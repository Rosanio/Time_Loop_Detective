extends StaticBody2D


@export var player: CharacterBody2D
@export var enterSpawnPoint: Node2D

@onready var camera: Camera2D = $"/root/Main/Player/Camera2D"

func _ready():
	($InteractableComponent as Interactable).interact.connect(on_interact)


func on_interact():
	# The only way I could find to reset the camera's drag offset was to disable it and enable it
	# again. However, the game seems to only recognize it if you add a delay between disabling and
	# enabling it. I think the compiler disregards a variable change if you set it back to the original
	# value in the same function, but adding an async delay gets it to register properly.
	camera.drag_horizontal_enabled = false
	camera.drag_vertical_enabled = false
	player.position = enterSpawnPoint.position
	await get_tree().create_timer(0.01).timeout
	camera.drag_horizontal_enabled = true
	camera.drag_vertical_enabled = true
