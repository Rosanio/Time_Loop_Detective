extends RefCounted

class_name TimeData

var hour: int
var minute: int
var am_pm: String
var ticks: int

func _init(_hour: int, _minute: int, _am_pm: String, _ticks: int = -1):
	hour = _hour
	minute = _minute
	am_pm = _am_pm
	if _ticks < 0:
		_ticks = to_ticks(_hour, _minute, _am_pm)
	ticks = _ticks


func _to_string() -> String:
	return str(hour) + ":" + str(minute) + "0 " + am_pm


func is_in_range(time1: TimeData, time2: TimeData) -> bool:
	if time1.ticks == time2.ticks:
		return true
	elif time1.ticks > time2.ticks:
		return ticks > time1.ticks or ticks < time2.ticks
	else:
		return ticks > time1.ticks and ticks < time2.ticks


static func to_ticks(_hour: int, _minutes: int, _am_pm: String):
	var _ticks = 0
	_ticks += _hour * 6
	if _am_pm == "PM":
		_ticks += 12 * 6
	_ticks += _minutes
	return _ticks


static func from_dict(time_dict: Dictionary) -> TimeData:
	return TimeData.new(time_dict["hour"], time_dict["minute"], time_dict["am_pm"])


static func from_ticks(_ticks: int) -> TimeData:
	var _hour = _ticks / 6
	if _ticks < 6:
		_hour = 12
	var _minutes = _ticks % 6
	var is_pm = _ticks >= 72
	if is_pm:
		_hour -= 12
	
	return TimeData.new(_hour, _minutes, "PM" if is_pm else "AM", _ticks)


static func is_time_equal(time1: TimeData, time2: TimeData) -> bool:
	return time1.hour == time2.hour && time1.minute == time2.minute && time1.am_pm == time2.am_pm
