extends CanvasLayer

@onready var tab_menu: ColorRect = $TabMenu


func _process(_delta: float):
	if Input.is_action_just_pressed("open_tab_menu"):
		toggle_tab_menu()


func toggle_tab_menu():
	tab_menu.visible = not tab_menu.visible
	get_tree().paused = tab_menu.visible
