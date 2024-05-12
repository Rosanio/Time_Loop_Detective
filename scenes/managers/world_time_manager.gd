extends Node

signal on_tick(time_ticks: Dictionary)

@onready var timer: Timer = $Timer

var time_ticks: int = 48


func _ready():
	timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	time_ticks += 1
	if time_ticks >= 144: time_ticks = 0
	
	var hour = time_ticks / 6
	if time_ticks < 6:
		hour = 12
	var minutes = time_ticks % 6
	var is_pm = time_ticks >= 72
	if is_pm:
		hour -= 12
	
	var time_dict = {
		"hour": hour,
		"minute": minutes,
		"am_pm": "PM" if is_pm else "AM"
	}
	on_tick.emit(time_dict)
