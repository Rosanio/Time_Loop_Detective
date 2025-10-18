extends CanvasLayer

const LABEL_WIDTH = 288
const LABEL_FULL_HEIGHT = 68
const LABEL_PROMPT_HEIGHT = 20
const DIALOG_BOX_PADDING = 6
const BUTTON_HEIGHT = 20


@onready var dialog_box: ColorRect = $DialogBox
@onready var label: Label = $'./DialogBox/VBoxContainer/DialogLabel'
@onready var button_container: VBoxContainer = $'./DialogBox/VBoxContainer/ButtonContainer'


func _ready():
	GameEvents.show_dialog.connect(show_dialog)
	GameEvents.show_dialog_prompt.connect(show_dialog_prompt)
	GameEvents.hide_dialog.connect(hide_dialog)


func show_dialog(dialog: String):
	show_dialog_box()
	label.size.y = LABEL_FULL_HEIGHT
	label.text = dialog


func show_dialog_prompt(dialog_prompt: Dictionary):
	show_dialog_box()
	label.size.y = LABEL_PROMPT_HEIGHT
	label.text = dialog_prompt["text"]
	var current_index = 0
	for option in dialog_prompt["options"]:
		var button: Button = Button.new()
		button.position = Vector2(
			DIALOG_BOX_PADDING,
			DIALOG_BOX_PADDING + LABEL_PROMPT_HEIGHT + (BUTTON_HEIGHT * current_index)
		)
		button.text = option
		button_container.add_child(button)
		current_index += 1



func hide_dialog():
	dialog_box.set_visible(false)


func show_dialog_box():
	if !dialog_box.visible: dialog_box.set_visible(true)
