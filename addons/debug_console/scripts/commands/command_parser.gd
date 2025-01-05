class_name DebugConsoleCommandParser

## Keys are Strings, corresponding to valid command keywords.
## Values are Callables, corresponding to actual command logic.
var command_dictionary: Dictionary = {}

## Registers a command with name, going to the corresponding callable.
## If command already exists, REPLACES existing entry.
## Callable should be a function that takes PackedStringArray (Args)
## and does not return anything (all side effects only).
func register(name: String, callable: Callable) -> void:
	command_dictionary[name] = callable
## Unregisters command with given name, if it exists.
func unregister(name: String) -> void:
	command_dictionary.erase(name)

func parse(input_string: String) -> void:
	## SPLIT INPUT STRING INTO SEGMENTS
	var space_separated_strings: PackedStringArray = input_string.strip_edges().split(" ", false)
	if len(space_separated_strings) == 0:
		printerr("Attempted to parse command, but found no command or arguments.")
		return
	
	## ISOLATE COMMAND AND ARGUMENTS
	var command: String = space_separated_strings[0]
	space_separated_strings.remove_at(0)
	var args: PackedStringArray = space_separated_strings
	
	## TRY CALL CORRESPONDING COMMAND
	var dictionary_entry = command_dictionary.get(command, null)
	if dictionary_entry is Callable:
		dictionary_entry.call(args)
	else:
		printerr("Unknown command: " + command)
