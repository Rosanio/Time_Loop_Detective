extends CanvasLayer

@onready var dialog_box: ColorRect = $DialogBox
@onready var label: Label = $'./DialogBox/DialogLabel'


func _ready():
	GameEvents.show_dialog.connect(show_dialog)


func show_dialog(dialog: String):
	dialog_box.set_visible(true)
	label.text = dialog
