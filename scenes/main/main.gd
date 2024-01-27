extends Node

var time_ticks = 48

func _ready():
	$HUD.update_world_clock(time_ticks)
	$WorldClock.start()


func _process(delta):
	pass


func _on_world_clock_timeout():
	time_ticks += 1
	if time_ticks >= 144: time_ticks = 0
	$HUD.update_world_clock(time_ticks)
