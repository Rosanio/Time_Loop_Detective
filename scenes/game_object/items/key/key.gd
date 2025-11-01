extends Area2D

@export var item_data: KeyItemData

@onready var item_component: Item = $ItemComponent

func _ready() -> void:
	item_component.item_data = item_data
