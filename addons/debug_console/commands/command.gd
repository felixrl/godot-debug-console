class_name DebugConsoleCommand

## ---
## DEBUG CONSOLE COMMAND
## A registered command that can be called
## ---

## A callable that takes a PackedStringArray for cli arguments and returns void
var callable: Callable # FUNCTION CALLED WITH ARGS
var short_help_desc: String
var long_help_desc: String

## Callable should contain all logic for the command
## Input: PackedStringArray (for args)
## Output: void
## SHORT BLURBS should be one sentence with no punctuation
## LONG DESCRIPTION should start with a USAGE: <command format> line
## then continue with indented lines in regular English punctuation describing behaviour.
func _init(c: Callable, short_help_desc: String = "", long_help_desc: String = ""):
	set_callable(c)
	set_short_help_desc(short_help_desc)
	set_long_help_desc(long_help_desc)

func set_callable(c: Callable) -> void:
	callable = c
func get_callable() -> Callable:
	return callable

func set_short_help_desc(d: String) -> void:
	short_help_desc = d
func get_short_help_desc() -> String:
	return short_help_desc
func set_long_help_desc(d: String) -> void:
	long_help_desc = d
func get_long_help_desc() -> String:
	return long_help_desc
