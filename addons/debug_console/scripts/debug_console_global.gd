extends Node

## DEBUG CONSOLE GLOBAL
## Autoload script for DebugConsole

## TODO
## - Logging system
## -- Keeping stack trace and events, etc.
## - Command system
## -- Input UI - How to bring up and not interfere with other inputs?
## -- Command parser - How to make it easy to send commands to game systems?
## --- Commands have to link in to other systems?

const VERSION = "0.0.1"

func _ready():
	var command_parser = DebugConsoleCommandParser.new()
	command_parser.register("hello", func (a): print(a))
	
	var pause_callable: Callable = func (args: PackedStringArray):
		get_tree().paused = !get_tree().paused
		print("Game paused: " + str(get_tree().paused))
	command_parser.register("pause", pause_callable)
	
	command_parser.parse("hello worlde e e eee")
	command_parser.parse(" helloo beans")
	command_parser.parse("   ")
	command_parser.parse("pause")

func _process(delta):
	pass
