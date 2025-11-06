extends Control
class_name InventoryMenuUI

@export var inventory: Inventory:
	set(value):
		inventory = value
		if inventory:
			connect_inventory_signals()

@onready var grid_container: GridContainer = $VBoxContainer/GridContainer
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel

var inventory_slots: Array[Node]

func _ready():
	inventory_slots = grid_container.get_children()
	for i in range(inventory_slots.size()):
		inventory_slots[i].focus_entered.connect(Callable(self, "button_focused").bind(i))


func connect_inventory_signals():
	inventory.item_added.connect(item_added)
	inventory.item_removed.connect(item_removed)


func item_added(item: ItemData, index: int):
	var button: Button = inventory_slots[index] as Button
	button.disabled = false
	button.focus_mode = Control.FOCUS_CLICK
	var texture: TextureRect = button.get_node("TextureRect")
	texture.visible = true
	texture.texture = item.icon


func item_removed(index: int):
	var button: Button = inventory_slots[index] as Button
	var texture: TextureRect = button.get_node("TextureRect")
	texture.texture = null
	texture.visible = false
	button.focus_mode = Control.FOCUS_NONE
	button.disabled = true


func button_focused(index: int):
	var item = inventory.inventory[index]
	name_label.text = item.name
	description_label.text = item.description
