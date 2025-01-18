class_name Logger

## LOGGER
## A basic interface for logging...

## ------ ##
## CONFIG ##
## ------ ##

const PRINT_TO_GODOT_CONSOLE = true # Console print flag
const MAX_ENTRIES = 1000 # Maximum allowable entries before removal of old ones

static var log_file_name: String = "debug_log"
static var log_file_extension: String = "txt"

## ---------- ##
## MAIN LOGIC ##
## ---------- ##

signal entry_logged(str: String)
static var entries: Array[String]

## Log an entry to the entries list.
static func log(str: String) -> void:
	entries.append("%s\n" % str)
	
	if len(entries) > MAX_ENTRIES:
		entries.remove_at(0)
	
	# print(get_stack()) ## IMPLEMENT STACK TRACE
	
	DebugConsole.console_ui.print_string(str + "\n") # TEMP SOLUTION
	
	## And to also show it in the Godot console...
	if PRINT_TO_GODOT_CONSOLE:
		print(str)
static func log_warning(str: String) -> void:
	entries.append("WARNING: %s\n" % str)
	
	if len(entries) > MAX_ENTRIES:
		entries.remove_at(0)
	
	DebugConsole.console_ui.print_string("[color=yellow]WARNING: " + str + "[/color]\n") # TEMP SOLUTION
	
	if PRINT_TO_GODOT_CONSOLE:
		push_warning(str)
static func log_error(str: String) -> void:
	entries.append("ERROR: %s\n" % str)
	
	if len(entries) > MAX_ENTRIES:
		entries.remove_at(0)
	
	DebugConsole.console_ui.print_string("[b][color=red]ERROR: " + str + "[/color][/b]\n") # TEMP SOLUTION
	
	if PRINT_TO_GODOT_CONSOLE:
		push_error(str)

## --------- ##
## LOG FILES ##
## --------- ##

## Dump log with filter; default no filter.
## Filter predicate takes String and returns bool.
static func dump_to_file(dir_path: String, filter_pred: Callable = func(x): return true) -> void:
	## TODO
	## - Dynamic directory generation if given directory that doesn't exist...
	
	## FIND UNIQUE FILE PATH BASED ON DATE
	var iteration: int = 0
	# var date_time: String = Time.get_datetime_string_from_system(false)
	var date_time: String = Time.get_date_string_from_system(false)
	# date_time = date_time.replace("-", "_")
	var file_path: String = ""
	
	while true:
		file_path = dir_path.path_join(log_file_name + "_" + date_time + "_" + str(iteration) + "." + log_file_extension)
		iteration += 1
		if not FileAccess.file_exists(file_path):
			break
	
	## OPEN FILE
	
	Logger.log("Dumping log to " + file_path)
	
	var new_file = FileAccess.open(file_path, FileAccess.WRITE)
	if not new_file:
		## ERROR opening new file!
		push_error("LOGGER: Attempt to open " + file_path + " failed.")
		return
	
	## STORE ENTRIES
	
	## TODO: First few lines should always be in the entries
	## before the filter kicks in...
	var filtered_entries = entries.filter(filter_pred)
	for entry: String in filtered_entries:
		new_file.store_string(entry)
	
	## CLOSE FILE
	
	new_file.store_string("\n-- END LOG --")
	new_file.close()

## Helper utility for generating predicate to filter for specific strings.
static func get_contains_str_pred(str: String) -> Callable:
	return func(s: String): return s.contains(str)
