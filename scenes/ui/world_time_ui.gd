extends CanvasLayer

@export var world_time_manager: Node

func _ready():
	world_time_manager.on_tick.connect(update_world_clock)


func update_world_clock(time: Dictionary):
	var time_string = str(time["hour"]) + ":" + str(time["minute"]) + "0 " + time["am_pm"]
	$TimeLabel.text = time_string
