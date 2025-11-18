extends RefCounted
class_name Completer

signal completed(value)

var is_completed := false
var value = null

func complete(v = null):
	if is_completed:
		return

	is_completed = true
	value = v
	completed.emit(v)


static func race(signals: Array) -> Signal:
	var c := Completer.new()
	for s in signals:
		s.connect(func(_v = null):
			if not c.is_completed:
				c.complete(s)
		, CONNECT_ONE_SHOT)
	return c.completed
