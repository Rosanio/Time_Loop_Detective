extends StaticBody2D

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var is_open := false


func _ready():
	($InteractableComponent as Interactable).interact.connect(on_interact)


func on_interact(player: CharacterBody2D):
	is_open = not is_open
	if not is_open:
		_ensure_player_clear(player)
	sprite.visible = !sprite.visible
	collider.disabled = !collider.disabled


func _ensure_player_clear(player: CharacterBody2D):
	var door_center = collider.global_position
	var door_size = (collider.shape as RectangleShape2D).size
	var door_position = door_center - Vector2(door_size / 2)
	var door_rect = Rect2(door_position, door_size)
	var player_collider_center = player.get_node("CollisionShape2D").global_position
	if door_rect.has_point(player_collider_center):
		if player_collider_center.y > door_center.y:
			player.global_position.y = door_rect.end.y
		else:
			player.global_position.y = door_rect.position.y
