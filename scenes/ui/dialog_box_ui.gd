extends Control

const LABEL_WIDTH = 288
const LABEL_FULL_HEIGHT = 68
const LABEL_PROMPT_HEIGHT = 20
const DIALOG_BOX_PADDING = 6
const BUTTON_HEIGHT = 20


@onready var dialog_box: ColorRect = $DialogBox
@onready var label: Label = $'./DialogBox/VBoxContainer/DialogLabel'
@onready var button_container: VBoxContainer = $'./DialogBox/VBoxContainer/ButtonContainer'


func _ready():
	GameEvents.show_dialog_text.connect(show_dialog_text)
	GameEvents.show_dialog_prompt.connect(show_dialog_prompt)
	GameEvents.hide_dialog.connect(hide_dialog)


func show_dialog_text(dialog: String):
	clear_buttons()
	show_dialog_box()
	label.size.y = LABEL_FULL_HEIGHT
	label.text = dialog


func show_dialog_prompt(dialog_prompt: Dictionary):
	clear_buttons()
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
		var format_button_text = "%d. " + option
		button.text = format_button_text % (current_index + 1)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button_container.add_child(button)
		button.connect("pressed", Callable(self, "_on_prompt_selected").bind(current_index))
		current_index += 1


func hide_dialog():
	dialog_box.set_visible(false)
	InputManager.current_context = InputManager.Context.WORLD


func show_dialog_box():
	if !dialog_box.visible: dialog_box.set_visible(true)
	InputManager.current_context = InputManager.Context.DIALOG


func _on_prompt_selected(index: int):
	GameEvents.emit_dialog_prompt_chosen(index)


func clear_buttons():
	for button in button_container.get_children():
		button.queue_free()
