# Debug Console

Introduces functionality for console input/output, logging, and custom commands for better Godot debugging and navigation during QA testing.

## Usage

The console is automatically added to the root of your Godot scene at runtime. To open the console, use the `F1` key. If your computer has functionality that triggers when `F1` is pressed (such as on a Macbook), use `fn + F1`.

## Logging

Currently, there is a static class called `Logger`

Log messages by calling `Logger.log("message")` from anywhere. There are also `Logger.log_warning("warning")` and `Logger.log_error("error")`.

In the `Logger` class, there are two constant flags.
- `PRINT_TO_GODOT_CONSOLE`, which dictates if your logging calls will also be printed to the console (NOTE: Warnings and errors are sent to the debugger instead of the main console if this is enabled).
- `MAX_ENTRIES`, which dictates how many discrete log entries will be stored in the list before they start to be cleared out oldest first.

## Commands

The Debug Console comes with a few built-in commands.

- `clear` — Clears the console.
- `close` — Closes the console the same way that the CLOSE CONSOLE button works.
- `quit` — Same as close.
- `pause` — Toggles the `paused` flag of the current `get_tree()` SceneTree.

The console uses a "command registry" dictionary. To register your own commands:

1. Create a `Callable` type (a function, anonymous function, lambda) which takes one parameter of type `PackedStringArray`. These are your command's arguments.
2. Define your command's logic and behaviour within the Calleable's body.
3. Call `DebugConsole.command_parser.register()` with your new command's name (e.g. the identifying keyword) and your Callable to register it. For example: 

	```
	DebugConsole.command_parser.register("hello", 
		func (args: PackedStringArray): print("hi!"))
	```
	This registers a command called `hello` which prints `hi!` to the regular Godot console every time it is executed via the console.

NOTE: The registration only persists per runtime. This means that your command(s) should be added at the loading stage of your game.

To remove a command from the registry, use `DebugConsole.command_parser.unregister()` with your command's name. e.g. `unregister("hello")`.
