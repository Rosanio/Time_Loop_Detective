extends Node

signal on_tick(time: TimeData)

@onready var timer: Timer = $Timer

var time_ticks: int = 48

func _ready():
	timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	time_ticks += 1
	if time_ticks >= 144: time_ticks = 0
	
	var time = TimeData.from_ticks(time_ticks)
	on_tick.emit(time)


func get_current_time():
	return TimeData.from_ticks(time_ticks)
