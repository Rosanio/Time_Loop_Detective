extends CanvasLayer

@onready var dialog_box: ColorRect = $DialogBox
@onready var label: Label = $'./DialogBox/DialogLabel'


func _ready():
	GameEvents.show_dialog.connect(show_dialog)
	GameEvents.hide_dialog.connect(hide_dialog)


func show_dialog(dialog: String):
	dialog_box.set_visible(true)
	label.text = dialog


func hide_dialog():
	dialog_box.set_visible(false)
