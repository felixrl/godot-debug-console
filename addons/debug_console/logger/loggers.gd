class_name Loggers

## ---
## LOGGERS
## A static registry for loggers
## ---

#region GLOBAL CONFIG

static var print_to_godot_console = DebugConsole.CONFIG.print_to_godot_console # Console print flag
static var max_entries = DebugConsole.CONFIG.max_entries_before_cutoff # Maximum allowable entries before removal of old ones

static var log_file_name: String = DebugConsole.CONFIG.log_file_name_prefix
static var log_file_extension: String = "txt"

static var strip_bbcode: bool = DebugConsole.CONFIG.strip_bbcode

#endregion

const DEFAULT_LOGGER: int = 0

static var loggers: Dictionary[int, Logger] = {}

## Attempts to get the logger with the given numerical ID
## If it doesn't exist, creates it (and uses the given name) and returns it
## NOTE: ID 0 is reserved for the general logger
static func get_logger(id: int = DEFAULT_LOGGER, _name: String = "") -> Logger:
	if loggers.has(id):
		return loggers.get(id)
	
	var logger: Logger = Logger.new(id, _name)
	loggers.set(id, logger)
	logger.entry_logged.connect(_on_entry_logged)
	
	return logger

static func _on_entry_logged(entry: LogEntry) -> void:
	## TODO: Move "Logger" source name addition to here..?
	DebugConsole.console_ui.print_string.call_deferred(entry.get_console_display_string(true))
	if print_to_godot_console:
		entry.print_to_godot_console(true)

#region STATIC DEFAULT INTERFACE

## Log an entry to the DEFAULT_LOGGER logger
static func log(str: String) -> void:
	get_logger().log(str)

## Log a warning to the DEFAULT_LOGGER logger
static func log_warning(str: String) -> void:
	get_logger().log_warning(str)

## Log an error to the DEFAULT_LOGGER logger
static func log_error(str: String) -> void:
	get_logger().log_error(str)

#endregion

#region LOG DUMPS

## Dumps all recorded log entries in the loggers of the corresponding IDs
## If the supplied IDs list is empty, dumps the logs of all loggers
## Optional filter should be in the form (LogEntry) -> bool
static func dump(dir_path: String, logger_ids: Array[int] = [], filter_pred: Callable = func(x: LogEntry): return true) -> void:
	## FIND UNIQUE FILE PATH BASED ON DATE
	var iteration: int = 0
	var date_time: String = Time.get_datetime_string_from_system(false)
	# var date_time: String = Time.get_date_string_from_system(false)
	date_time = date_time.replace("-", "_")
	var file_path: String = ""
	
	while true:
		file_path = dir_path.path_join(log_file_name + "_" + date_time + "_" + str(iteration) + "." + log_file_extension)
		iteration += 1
		if not FileAccess.file_exists(file_path):
			break
	
	## OPEN FILE
	get_logger().log("Dumping log to %s..." % file_path)
	
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	var new_file = FileAccess.open(file_path, FileAccess.WRITE)
	if not new_file:
		## ERROR opening new file!
		get_logger().log_error("LOGGER: Attempt to open " + file_path + " failed.")
		return
	
	## STORE ENTRIES
	new_file.store_string(DebugConsole.game_name + " v" + DebugConsole.game_version + " by " + DebugConsole.studio_name + "\n")
	new_file.store_string("DebugConsole v%s | Debug Log\n" % DebugConsole.VERSION)
	new_file.store_string("Dumped at " + Time.get_datetime_string_from_system(false) + " | Maximum " + str(max_entries) + " entries before cutoff\n")
	new_file.store_string("-- BEGIN LOG --\n")

	var ids_to_check = logger_ids
	if logger_ids.is_empty():
		ids_to_check = loggers.keys()

	var all_entries: Array[LogEntry] = []
	for id: int in ids_to_check:
		if loggers.has(id):
			all_entries.append_array(loggers.get(id).get_entries())
	all_entries.sort_custom(_sort_entries_by_time) ## SORT BY TIME
	all_entries = all_entries.filter(filter_pred) ## FILTER BY CRITERIA

	for entry: LogEntry in all_entries:
		if strip_bbcode:
			new_file.store_string(strip_bbcode_tags(entry.get_console_display_string(true)))
		else:
			new_file.store_string(entry.get_console_display_string(true))
	
	## CLOSE FILE
	new_file.store_string("-- END LOG --")
	new_file.close()
	
	get_logger().log("Log successfully dumped to %s" % file_path)

static func _sort_entries_by_time(a: LogEntry, b: LogEntry) -> bool:
	if a.timestamp < b.timestamp:
		return true
	return false

#endregion

#region HELPERS

## Helper utility for generating predicate to filter for specific strings.
static func get_contains_str_pred(str: String) -> Callable:
	return func(s: String): return s.contains(str)

## Helper function for stripping BBCode tags
static var regex = RegEx.new()
static func strip_bbcode_tags(str: String) -> String:
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(str, "", true)
	return text_without_tags

#endregion
