extends Node

signal show_dialog_text(dialog: String, speaker: String)
signal show_dialog_prompt(dialog_prompt: Dictionary, speaker: String)
signal hide_dialog
signal dialog_prompt_chosen(index: int)
signal show_speech_bubble(speaker: Node, text: String, duration: int)


func emit_show_dialog_text(dialog: String, speaker: String):
	show_dialog_text.emit(dialog, speaker)


func emit_show_dialog_prompt(dialog_prompt: Dictionary, speaker: String):
	show_dialog_prompt.emit(dialog_prompt, speaker)


func emit_hide_dialog():
	hide_dialog.emit()


func emit_dialog_prompt_chosen(index: int):
	dialog_prompt_chosen.emit(index)


func emit_show_speech_bubble(speaker: Node, text: String, duration: int = 3):
	show_speech_bubble.emit(speaker, text, duration)
