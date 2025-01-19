extends Node

## DEBUG CONSOLE GLOBAL
## Autoload script for DebugConsole



#region CONFIG

## Always loads the CONFIG file from the plugin folder
## Change this path if another CONFIG file is used
const CONFIG: DebugConsoleConfig = preload("res://addons/debug_console/CONFIG.tres")
const VERSION = "0.0.1" # DEBUG CONSOLE PLUGIN VERSION

## Relevant information pulled from PROJECT SETTINGS
@onready var game_name = ProjectSettings.get_setting("application/config/name")
@onready var game_version = _get_game_version()
func _get_game_version() -> String:
	var version: String = ProjectSettings.get_setting("application/config/version").strip_edges()
	if version.is_empty():
		return "<no version>"
	if version.substr(0, 1) == "v":
		return version.substr(1)
	return version

@onready var studio_name = CONFIG.studio_name

#endregion

#region SETUP

const CONSOLE_UI_SCENE = preload("./console_ui/console_ui.tscn")

var console_ui: ConsoleUI
var command_parser: DebugConsoleCommandParser

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Always processing, debug is.
	
	setup_command_parser()
	setup_console_ui()
	register_default_commands()
	
	Logger.log.call_deferred(game_name + " v" + game_version + " by " + studio_name)
	Logger.log.call_deferred("DebugConsole v%s by felixrl" % VERSION)
	Logger.log.call_deferred("Debugging started at %s\n" % Time.get_datetime_string_from_system(false))
	# Logger.log.call_deferred("Dumped at " + Time.get_datetime_string_from_system(false) + " | Maximum " + str(Logger.MAX_ENTRIES) + " lines before cutoff")
	# Logger.log.call_deferred("-- BEGIN LOG --\n")

func setup_command_parser() -> void:
	command_parser = DebugConsoleCommandParser.new()

func setup_console_ui() -> void:
	console_ui = CONSOLE_UI_SCENE.instantiate()
	get_tree().root.add_child.call_deferred(console_ui) # Wait until root is done init...
	
	## WIRE UP COMMAND SUBMISSION
	console_ui.command_submitted.connect(command_parser.parse_and_try_execute)
	
	## WIRE UP LOGGER
	## ??? Should logger be instanced?

func register_default_commands() -> void:
	## TESTING
	var hello_callable: Callable = func (args: PackedStringArray):
		var all_args = ""
		for str: String in args:
			all_args += " " + str
		Logger.log("Hello" + all_args + "!")
	
	command_parser.register("hello", hello_callable)
	
	## HELP..?
	command_parser.register("help", func(args): Logger.log("Unfortunately, there is no help."))
	
	## CLEAR CONSOLE
	var clear_callable: Callable = func (args: PackedStringArray):
		console_ui.clear()
		Logger.log("Console cleared.\n")
	command_parser.register("clear", clear_callable)
	
	## TOGGLE PAUSE/SET PAUSE
	var toggle_pause_callable: Callable = func (args: PackedStringArray):
		get_tree().paused = !get_tree().paused
		Logger.log("[b]GAME PAUSED[/b]: " + str(get_tree().paused) + ". Type toggle-pause to toggle back.")
	command_parser.register("toggle-pause", toggle_pause_callable)
	
	var set_pause_callable: Callable = func (args: PackedStringArray):
		if len(args) < 1 or (not args[0] == "true" and not args[0] == "false"):
			Logger.log_error("set-pause expects an argument of either true or false.")
		else:
			if args[0] == "true":
				get_tree().paused = true
				Logger.log("[b]Game paused.[/b] Use set-pause or toggle-pause to unpause.")
			elif args[0] == "false":
				get_tree().paused = false
				Logger.log("[b]Game unpaused.[/b] Use set-pause or toggle-pause to pause.")
	command_parser.register("set-pause", set_pause_callable)
	
	## CLOSE CONSOLE
	command_parser.register("close", func(args): console_ui.close())
	## QUIT GAME
	command_parser.register("quit", func(args): get_tree().quit())
	
	## DUMP LOG
	var dump_callable: Callable = func (args: PackedStringArray):
		if len(args) < 1 or args[0].is_empty():
			Logger.dump_to_file(CONFIG.default_logs_directory_path)
		else:
			Logger.dump_to_file(args[0])
	command_parser.register("dump", dump_callable)
	command_parser.register("dump-log", dump_callable)

#endregion

#region INPUT HANDLING

const CONSOLE_TOGGLE_KEY = KEY_F1
const DUMP_LOG_KEY = KEY_F3

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(CONSOLE_TOGGLE_KEY) and just_pressed:
		console_ui.toggle()
	if Input.is_key_pressed(DUMP_LOG_KEY) and just_pressed:
		Logger.log("F3 shortcut pressed")
		Logger.dump_to_file(CONFIG.default_logs_directory_path)

#endregion