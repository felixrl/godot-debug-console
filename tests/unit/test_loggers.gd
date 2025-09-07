extends GutTest

func test_default_logger() -> void:
	Loggers.log("Hello world!")
	assert_eq(Loggers.get_logger().get_entries().back().content, "Hello world!")

func test_named_loggers() -> void:
	Loggers.get_logger(1, "Special Logger").log("Special announcement...")
	assert_eq(Loggers.get_logger(1, "Normie Logger").get_entries().back().get_console_display_string(true), "Special Logger | Special announcement...\n")
	assert_eq(Loggers.get_logger(1, "Normie Logger").get_entries().back().get_console_display_string(false), "Special announcement...\n")
