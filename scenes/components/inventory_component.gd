extends Node
class_name Inventory

signal item_added
signal item_removed

@onready var items_container: Node = $"/root/Main/Items"

var inventory: Array[ItemData]

func add_item(item: Item):
	add_item_data(item.item_data)
	ItemsRegistry.remove(item.item_data.id)
	if get_parent() is Player:
		GameEvents.emit_player_picked_up_item(item)
	item.queue_free()


func add_item_data(item_data: ItemData):
	inventory.append(item_data)
	emit_item_added(item_data, inventory.size() - 1)


func emit_item_added(item: ItemData, index: int):
	item_added.emit(item, index)


func drop_item_by_id(item_id: String):
	var items = inventory.filter(func(item_data): return item_data.id == item_id)
	if items.size() != 1: return

	drop_item(items[0])


func drop_item(item_data: ItemData):
	var item_scene = load(item_data.scene_path)
	var item = item_scene.instantiate()
	item.item_data = item_data
	item.global_position = get_parent().global_position
	items_container.add_child(item)
	if get_parent() is Player:
		GameEvents.emit_player_dropped_item(item)

	var item_index = inventory.find_custom(func(i): return i.id == item_data.id)
	remove_item(item_index)


func remove_item(item_index: int):
	inventory.pop_at(item_index)
	item_removed.emit(item_index)


func has_key(door: Door):
	for item in inventory:
		if item is KeyItemData and item.door_id == door.id:
			return true
	return false


func has_item(item_id: String):
	return inventory.any(func(item): return item.id == item_id)


func transfer_item_to(item_id: String, other_inventory: Inventory):
	if not has_item(item_id):
		return

	var item_index = inventory.find_custom(func(item): return item.id == item_id)
	other_inventory.add_item_data(inventory[item_index])
	remove_item(item_index)
