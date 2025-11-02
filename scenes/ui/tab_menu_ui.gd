extends Control

@export var player: CharacterBody2D

@onready var tab_menu: ColorRect = $TabMenu
@onready var inventory_menu: InventoryMenuUI = $TabMenu/VBoxContainer/MarginContainer/InventoryUI


func _ready():
	# Wait one frame to allow time for the player inventory component to initialize
	await get_tree().process_frame
	if player and player.inventory:
		inventory_menu.inventory = player.inventory


func _process(_delta: float):
	if Input.is_action_just_pressed("open_tab_menu"):
		toggle_tab_menu()


func toggle_tab_menu():
	tab_menu.visible = not tab_menu.visible
	get_tree().paused = tab_menu.visible
	if inventory_menu.inventory_slots.size() > 0:
		(inventory_menu.inventory_slots[0] as Button).grab_focus()
