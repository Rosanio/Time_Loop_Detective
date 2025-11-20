extends StaticBody2D
class_name Door

@export var id: String
@export var is_locked: bool

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var is_open := false


func _ready():
	($InteractableArea/InteractableComponent as Interactable).interact.connect(on_interact)


func on_interact(interactor: Node):
	if interactor is Player:
		handle_player_interaction(interactor)
	elif interactor is Npc:
		handle_npc_interaction(interactor)


func handle_player_interaction(player: Player):
	if is_locked:
		if player.inventory.has_key(self):
			is_locked = false
		else:
			GameEvents.emit_show_speech_bubble(player, "It's locked", 3)
			return

	is_open = not is_open
	if not is_open:
		ensure_player_clear(player)
	sprite.visible = !sprite.visible
	collider.disabled = !collider.disabled


func handle_npc_interaction(npc: Npc):
	if is_locked and not npc.inventory.has_key(self):
		npc.handle_missing_key(self)
		return
	sprite.visible = false
	await get_tree().create_timer(0.5).timeout
	sprite.visible = true


func ensure_player_clear(player: Player):
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
