extends Node

signal show_dialog_text(dialog: String)
signal show_dialog_prompt(dialog_prompt: Dictionary)
signal hide_dialog()
signal dialog_prompt_chosen(index: int)


func emit_show_dialog_text(dialog: String):
	show_dialog_text.emit(dialog)


func emit_show_dialog_prompt(dialog_prompt: Dictionary):
	show_dialog_prompt.emit(dialog_prompt)


func emit_hide_dialog():
	hide_dialog.emit()


func emit_dialog_prompt_chosen(index: int):
	dialog_prompt_chosen.emit(index)
