extends Node

var registry = {}

func register_item(id: String, item: Node2D):
	registry[id] = item


func get_item(id: String):
	return registry.get(id)


func remove(id: String):
	registry.erase(id)
