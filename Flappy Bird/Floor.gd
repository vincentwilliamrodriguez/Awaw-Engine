extends StaticBody2D

func _physics_process(delta):
	print(get_parent().get_child_count())
	if get_parent().get_child_count() < 3 and position.x <= 0:
		var f = self.duplicate()
		f.position.x = 2470
		get_parent().add_child(f)
		
	if position.x <= -2560:
		queue_free()
	
	position.x -= 1000 * delta
