extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time := 0.0
func _process(delta):
	time += delta
	
	# Logger.log("Hello world!, %s" % str(time))
