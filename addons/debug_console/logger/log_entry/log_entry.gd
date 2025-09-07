class_name LogEntry
extends RefCounted

## ---
## LOG ENTRY
## One entry in a particular log
## ---

enum Type {
	LOG,
	WARNING,
	ERROR
}

var timestamp: int = 0
var content: String = ""
var type: Type = Type.LOG

var _logger: Logger

func _init(_content: String, _type: Type = Type.LOG, _timestamp: int = Time.get_ticks_usec()) -> void:
	timestamp = _timestamp
	content = _content
	type = _type

func set_logger(l: Logger) -> void:
	_logger = l

#region PRINTING

func get_console_display_string(include_logger_name: bool = false) -> String:
	var res := ""
	if include_logger_name and _logger.logger_name != "":
		res += _logger.logger_name + " | "
	match type:
		Type.WARNING:
			res += "[color=yellow]" + content + "[/color]"
		Type.ERROR:
			res += "[b][color=red]" + content + "[/color][/b]"
		_:
			res += content
	res += "\n"
	return res
func print_to_godot_console(include_logger_name: bool = false) -> void:
	var prefix: String = ""
	if include_logger_name and _logger.logger_name != "":
		prefix += _logger.logger_name + " | "
	
	match type:
		Type.WARNING:
			print(prefix + "WARNING: " + content)
			push_warning(content)
		Type.ERROR:
			printerr(prefix + "ERROR: " + content)
			push_error(content)
		_:
			print(prefix + content)

#endregion

#region TIMESTAMP

## Get the rough "second" approximation of the timestamp
func get_timestamp_seconds() -> float:
	return float(timestamp) / 1_000_000.00
func get_timestamp_string() -> String:
	var arr: Array = time_extract(get_timestamp_seconds())
	var result: String = "{d}:{h}:{m}:{s}:{ms}".format({
		"d": arr[0],
		"h": arr[1],
		"m": arr[2],
		"s": arr[3],
		"ms": arr[4]
	})
	return result

## Too lazy to write this...
## https://gamedevfcups.com/time-extracting-function-in-godot-engine/
#========TIME EXTRACTION========
func time_extract(my_time) -> Array:
	var days = 0
	var hours = 0
	var minutes = 0
	var seconds = 0
	var mill_seconds = 0
	
	var time_array = [days, hours, minutes, seconds, mill_seconds]
	
	if my_time < 1: # less than a second
		mill_seconds = get_mill_seconds(my_time)
	elif int(my_time) in range(1, 60): # less than a minute
		mill_seconds = get_mill_seconds(my_time)
		seconds = get_seconds(my_time)
	elif int(my_time) in range(60, 3600): # less than an hour
		mill_seconds = get_mill_seconds(my_time)
		seconds = get_seconds(my_time)
		minutes = get_minutes(my_time)
	elif int(my_time) in range(3600, 86400): # less than a day
		mill_seconds = get_mill_seconds(my_time)
		seconds = get_seconds(my_time)
		minutes = get_minutes(my_time)
		hours = get_hours(my_time)
	elif int(my_time) >= 86400: # more than one day
		mill_seconds = get_mill_seconds(my_time)
		seconds = get_seconds(my_time)
		minutes = get_minutes(my_time)
		hours = get_hours(my_time)
		days = get_days(my_time)
	
	time_array[0] = days
	time_array[1] = hours
	time_array[2] = minutes
	time_array[3] = seconds
	time_array[4] = mill_seconds
	
	for i in range(time_array.size()):
		if time_array[i] < 10:
			time_array[i] = "0" + str(time_array[i])
		else:
			time_array[i] = str(time_array[i])
	
	return time_array

func get_mill_seconds(t):
	return int((t - floor(t)) * 100)

func get_seconds(t):
	t = floor(t)
	var mnts = floor(t/60)
	return t - (mnts * 60)

func get_minutes(t):
	t = floor(t)
	var hrs = floor(t/3600)
	return floor((t - (hrs * 3600))/60)

func get_hours(t):
	t = floor(t)
	var dys = floor(t/86400)
	return floor((t - (dys * 86400))/3600)

func get_days(t):
	return floor(t/86400)
#========TIME EXTRACTION END========

#endregion
