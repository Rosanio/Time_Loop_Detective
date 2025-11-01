extends Node
class_name Inventory

signal item_added

var inventory: Array[ItemData]

func add_item(item: Item):
	inventory.append(item.item_data)
	emit_item_added(item.item_data, inventory.size() - 1)
	item.get_parent().queue_free()


func emit_item_added(item: ItemData, index: int):
	item_added.emit(item, index)


func has_key(door: Door):
	for item in inventory:
		if item is KeyItemData and item.door_id == door.id:
			return true
	return false
