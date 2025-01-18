extends Node

## DEBUG CONSOLE GLOBAL
## Autoload script for DebugConsole

## TODO
## - Logging system
## -- Keeping stack trace and events, etc.
## -- Choose a log path to write to?
## - Command system
## -- Interference prevention? (Is this necessary???) (Maybe just pause?)

const GAME_NAME = "Untitled Game"
const GAME_VERSION = "1.0.0"
const STUDIO_NAME = "Untitled Studio"

const VERSION = "0.0.1"

const CONSOLE_UI_SCENE = preload("./console/console_ui.tscn")

var console_ui: ConsoleUI
var command_parser: DebugConsoleCommandParser

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Always processing, debug ha.
	
	setup_command_parser()
	setup_console_ui()
	setup_default_commands()
	
	Logger.log.call_deferred(GAME_NAME + " v" + GAME_VERSION + " | " + STUDIO_NAME)
	Logger.log.call_deferred("DebugConsole v%s | Debug Log" % DebugConsole.VERSION)
	Logger.log.call_deferred("Dumped at " + Time.get_datetime_string_from_system(false) + " | Maximum " + str(Logger.MAX_ENTRIES) + " lines before cutoff")
	Logger.log.call_deferred("-- BEGIN LOG --\n")

func setup_command_parser() -> void:
	command_parser = DebugConsoleCommandParser.new()

func setup_console_ui() -> void:
	console_ui = CONSOLE_UI_SCENE.instantiate()
	get_tree().root.add_child.call_deferred(console_ui) # Wait until root is done init...
	
	## WIRE UP COMMAND SUBMISSION
	console_ui.command_submitted.connect(command_parser.parse_and_try_execute)
	
	## WIRE UP LOGGER
	## ??? Should logger be instanced?

func setup_default_commands() -> void:
	command_parser.register("hello", func (a: PackedStringArray): Logger.log("Hello world!"))
	command_parser.register("clear", func (args): 
		console_ui.clear()
		Logger.log("Console cleared.\n"))
	
	var pause_callable: Callable = func (args: PackedStringArray):
		get_tree().paused = !get_tree().paused
		Logger.log("[b]GAME PAUSED[/b]: " + str(get_tree().paused))
	command_parser.register("pause", pause_callable)
	
	command_parser.register("close", func (args): console_ui.close())
	command_parser.register("quit", func (args): console_ui.close())

## SHORTCUT CHECKS

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_F1) and just_pressed:
		console_ui.toggle()
