extends CanvasLayer

func _ready():
	WorldTimeManager.on_tick.connect(update_world_clock)


func update_world_clock(time: TimeData):
	$TimeLabel.text = time.to_string()
