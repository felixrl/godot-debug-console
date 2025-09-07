class_name ConsoleUI
extends Control

signal command_submitted(string: String)

## ---
## CONSOLE UI
## Added to root node of game tree at runtime
## The UI for controling the console
## ---

## BUG: Potential interference with game pausing/pause menus
## and console if pause_on_open is on 

@onready var console_ui_root = %ConsoleUIRoot

@onready var output_text = %OutputText
@onready var text_input = %TextInput
@onready var enter_button: EnterButton = %EnterButton
@onready var close_button = %CloseButton

@onready var font_size = DebugConsole.CONFIG.font_size
@onready var pause_on_open = DebugConsole.CONFIG.pause_tree_when_open

var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # The console never sleeps.
	
	_init_style()
	
	text_input.text_changed.connect(_on_text_input_changed)
	text_input.text_submitted.connect(_on_text_input_submitted)
	text_input.keep_editing_on_text_submit = true ## Ensures that pressing enter keeps the input in the line edit
	
	enter_button.disable() # Starts disabled.
	enter_button.pressed.connect(_on_enter_button_pressed)
	
	close_button.pressed.connect(close)
	
	## START HIDDEN
	close()

func _init_style() -> void:
	## SETUP FONT SIZE
	output_text.add_theme_font_size_override("normal_font_size", font_size)
	output_text.add_theme_font_size_override("bold_font_size", font_size)
	output_text.add_theme_font_size_override("bold_italics_font_size", font_size)
	output_text.add_theme_font_size_override("italics_font_size", font_size)
	output_text.add_theme_font_size_override("mono_font_size", font_size)
	text_input.add_theme_font_size_override("font_size", font_size)
	enter_button.add_theme_font_size_override("font_size", font_size)
	close_button.add_theme_font_size_override("font_size", font_size)

func _input(event: InputEvent) -> void:
	if text_input.has_focus():
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.physical_keycode == KEY_UP:
				text_input.text = navigate_back()
			elif event.physical_keycode == KEY_DOWN:
				text_input.text = navigate_forward()
			#elif event.physical_keycode == KEY_TAB:
				### Attempt autocomplete for the current argument based on logic from root directory path
				#attempt_autocomplete_path()

#region OPEN/CLOSE

## Toggles the console's visibility
func toggle() -> void:
	close() if is_open else open_and_focus()

## Opens the console
func open() -> void:
	console_ui_root.show()
	focus_mode = Control.FOCUS_ALL
	is_open = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if pause_on_open:
		get_tree().paused = true
## Open + focus on typing
func open_and_focus() -> void:
	open()
	text_input.grab_focus()
## Closes the console
func close() -> void:
	console_ui_root.hide() # HAVE TO SHOW/HIDE ROOT INSIDE OF THE CANVAS LAYER
	focus_mode = Control.FOCUS_NONE
	is_open = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if pause_on_open:
		get_tree().paused = false

#endregion

#region TEXT OUTPUT LOGIC

## Print, including new line character
func print_new_line(string: String) -> void:
	output_text.text += "\n" + string
## Print, without new line character
func print_string(string: String) -> void:
	output_text.text += string
func clear() -> void:
	output_text.text = ""

#endregion

#region TEXT INPUT LOGIC

## Enable the enter button if text actually contains something
## Otherwise, disable the enter button
func _on_text_input_changed(text: String) -> void:
	var text_content := text.strip_edges()
	if text_content.is_empty():
		enter_button.disable()
	else:
		enter_button.enable()

## If there is actual content, signal command and clear input
## Otherwise, do nothing
func _try_submit_text_input() -> void:
	var string = text_input.text.strip_edges()
	if string.is_empty(): # Literally nothing.
		return
	
	command_submitted.emit(string)
	add_command_to_history(string)
	
	text_input.text = ""
	enter_button.disable()
	text_input.call_deferred("grab_focus")

## UI ways to submit the text input
func _on_text_input_submitted(_text: String) -> void:
	_try_submit_text_input()
func _on_enter_button_pressed() -> void:
	_try_submit_text_input()

#endregion

#region COMMAND HISTORY

var history: Array[String] = []
var navigation_head: int = 0

func add_command_to_history(line: String) -> void:
	history.append(line)
	navigation_head = history.size()

func navigate_back() -> String:
	navigation_head -= 1
	if navigation_head < 0:
		navigation_head = -1
		return ""
	return history[navigation_head]

func navigate_forward() -> String:
	navigation_head += 1
	if navigation_head >= history.size():
		navigation_head = history.size()
		return ""
	return history[navigation_head]

#endregion

#region AUTOCOMPLETE

## TODO: Implement autocomplete.

#endregion
