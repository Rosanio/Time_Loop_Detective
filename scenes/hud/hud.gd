extends CanvasLayer

var hour = 8
var minutes = 0

func _ready():
	pass


func _process(delta):
	pass
	
func update_world_clock(time):
	hour = time / 6
	if time < 6: hour = 12
	minutes = time % 6
	var is_pm = time >= 72
	if is_pm: hour -= 12
	var time_string = str(hour) + ":" + str(minutes) + "0 " + ("PM" if is_pm else "AM")
	$TimeLabel.text = time_string
