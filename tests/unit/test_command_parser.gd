extends GutTest

func test_invalid_command() -> void:
	DebugConsole.command_parser.parse_and_try_execute("beans")
	assert_eq(Loggers.get_logger().get_entries().back().content, "ERROR: Unknown command: beans")

func test_blank_command() -> void:
	DebugConsole.command_parser.parse_and_try_execute("    ")
	assert_eq(Loggers.get_logger().get_entries().back().content, "ERROR: Attempted to parse command, but found no command or arguments.")

func test_register_command() -> void:
	DebugConsole.register("my_cmd", func (args: PackedStringArray) -> void:
		Loggers.log("42")
		Loggers.log("END"),
		"", "")
	DebugConsole.command_parser.parse_and_try_execute("my_cmdlet")
	assert_eq(Loggers.get_logger().get_entries().back().content, "ERROR: Unknown command: my_cmdlet")
	
	DebugConsole.command_parser.parse_and_try_execute("my_cmd")
	assert_eq(Loggers.get_logger().get_entries()[-2].content, "42")
	assert_eq(Loggers.get_logger().get_entries()[-1].content, "END")
