extends Node
class_name Inventory

signal item_added
signal item_removed

var inventory: Array[ItemData]

func add_item(item: Item):
	add_item_data(item.item_data)
	item.get_parent().queue_free()


func add_item_data(item_data: ItemData):
	inventory.append(item_data)
	emit_item_added(item_data, inventory.size() - 1)


func emit_item_added(item: ItemData, index: int):
	item_added.emit(item, index)


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
