class_name Loggers
extends RefCounted

## ---
## LOGGERS
## A registry for loggers
## ---

const DEFAULT_LOGGER: int = 0

static var loggers: Dictionary[int, Logger] = {}

func get_logger(id: int = DEFAULT_LOGGER) -> Logger:
	return loggers.get_or_add(id, Logger.new())
