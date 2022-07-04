extends KinematicBody2D

const G = 4000
var v = Vector2(0,0)
var isAI = false
signal gameOver

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	Apply(0, G * delta)
	
	v.y = clamp(v.y, -3000, 4000)
	var collided = move_and_collide(v * delta)
	
	if collided:
		GameOver()
	
	rotation_degrees = -20 if v.y < 1000 else 20

func _input(event):
	if event.is_action_pressed("click"):
		v.y = -2400

func Apply(x, y):
	v += Vector2(x, y)

func GameOver():
	if !isAI:
		emit_signal("gameOver")
	queue_free()
