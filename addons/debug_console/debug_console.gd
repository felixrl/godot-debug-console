@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("DebugConsole", "res://addons/debug_console/scripts/debug_console_global.gd")

func _exit_tree():
	remove_autoload_singleton("DebugConsole")
