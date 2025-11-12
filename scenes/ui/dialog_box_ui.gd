extends Control

const LABEL_WIDTH = 288
const LABEL_FULL_HEIGHT = 68
const LABEL_PROMPT_HEIGHT = 20
const DIALOG_BOX_PADDING = 6
const BUTTON_HEIGHT = 20


@onready var dialog_box: ColorRect = $DialogBox
@onready var name_label: Label = $"./DialogBox/VBoxContainer/NameLabel"
@onready var dialog_label: Label = $'./DialogBox/VBoxContainer/DialogLabel'
@onready var button_container: VBoxContainer = $'./DialogBox/VBoxContainer/ButtonContainer'
@onready var normal_font = FontVariation.new()
@onready var italic_font = FontVariation.new()


func _ready():
	GameEvents.hide_dialog.connect(hide_dialog)
	normal_font.base_font = load("res://fonts/OpenSans-VariableFont_wdth,wght.ttf")
	normal_font.variation_embolden = 0.5
	italic_font.base_font = load("res://fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf")
	italic_font.variation_embolden = 0.5
	name_label.add_theme_font_override("font", normal_font)
	dialog_label.add_theme_font_override("font", normal_font)


func show_dialog_text(dialog: String, speaker: String):
	clear_buttons()
	show_dialog_box(speaker)
	dialog_label.size.y = LABEL_FULL_HEIGHT
	dialog_label.text = dialog
	# No speaker means the narrator is speaking
	if speaker == "":
		name_label.visible = false
		dialog_label.add_theme_font_override("font", italic_font)
	else:
		name_label.visible = true
		dialog_label.add_theme_font_override("font", normal_font)


func show_dialog_prompt(dialog_prompt: Dictionary, speaker: String):
	clear_buttons()
	show_dialog_box(speaker)
	dialog_label.size.y = LABEL_PROMPT_HEIGHT
	dialog_label.text = dialog_prompt["text"]
	var current_index = 0
	for option in dialog_prompt["options"]:
		var button: Button = Button.new()
		button.position = Vector2(
			DIALOG_BOX_PADDING,
			DIALOG_BOX_PADDING + LABEL_PROMPT_HEIGHT + (BUTTON_HEIGHT * current_index)
		)
		var format_button_text = "%d. " + option["text"]
		button.text = format_button_text % (current_index + 1)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_override("font", normal_font)
		button_container.add_child(button)
		button.connect("pressed", Callable(self, "_on_prompt_selected").bind(current_index))
		current_index += 1


func hide_dialog():
	dialog_box.set_visible(false)
	InputManager.current_context = InputManager.Context.WORLD


func show_dialog_box(speaker: String):
	if !dialog_box.visible: dialog_box.set_visible(true)
	name_label.text = speaker
	InputManager.current_context = InputManager.Context.DIALOG


func _on_prompt_selected(index: int):
	GameEvents.emit_dialog_prompt_chosen(index)


func clear_buttons():
	for button in button_container.get_children():
		button.queue_free()
