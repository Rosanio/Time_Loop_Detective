extends Control

@onready var label: Label = $ColorRect/TimeLabel

func _ready():
	WorldTimeManager.on_tick.connect(update_world_clock)


func update_world_clock(time: TimeData):
	label.text = time.to_string()
