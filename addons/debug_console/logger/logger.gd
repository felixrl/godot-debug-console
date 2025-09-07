class_name Logger

signal entry_logged(entry: LogEntry)
signal warning_logged(entry: LogEntry)
signal error_logged(entry: LogEntry)

## ---
## LOGGER
## A logger for a certain category
## Logged outputs go to console(s)
## ---

var id: int
var logger_name: String

var _entries: Array[LogEntry]

func _init(_id: int = 0, _name: String = &"") -> void:
	id = _id
	logger_name = _name

#region LOGGING

## Log a regular log message
func log(str: String) -> void:
	var new_entry := LogEntry.new(str, LogEntry.Type.LOG)
	log_entry(new_entry)

## Log a warning message
func log_warning(str: String) -> void:
	str = "WARNING: %s" % str
	var new_entry := LogEntry.new(str, LogEntry.Type.WARNING)
	log_entry(new_entry)
	
	warning_logged.emit(new_entry)

## Log an error message
func log_error(str: String) -> void:
	str = "ERROR: %s" % str
	var new_entry := LogEntry.new(str, LogEntry.Type.ERROR)
	log_entry(new_entry)
	
	error_logged.emit(new_entry)

## Log an entry object to this logger
func log_entry(entry: LogEntry) -> void:
	entry.set_logger(self)
	_entries.append(entry)
	entry_logged.emit(entry)
	
	if len(_entries) > Loggers.max_entries: ## Control maximum
		_entries.remove_at(0)

#endregion

#region LOG DUMPS

func get_entries() -> Array[LogEntry]:
	return _entries

#endregion
