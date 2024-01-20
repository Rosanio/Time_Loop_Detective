extends CharacterBody2D

const SPEED = 80;

func _ready():
	pass


func _process(delta):
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");
	var direction = Vector2(x_movement, y_movement).normalized()
	velocity = SPEED * direction
	
	move_and_slide()
