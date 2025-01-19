extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Logger.log("This is a test print from test.gd")
	Logger.log_warning("This is a test warning.")
	Logger.log_error("Uh oh! Test error.")
	
	DebugConsole.register("eh", func(args): Logger.log("Eh!"))
	DebugConsole.unregister("eh")

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time := 0.0
func _process(delta):
	time += delta
	
	# Logger.log("Hello world!, %s" % str(time))
