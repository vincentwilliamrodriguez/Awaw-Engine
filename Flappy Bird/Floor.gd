extends StaticBody2D

var spawned = false
const names = ["Floor 1", "Floor 2", "Floor 3"]

func _physics_process(delta):
	if !spawned and position.x <= 0:
		var f = self.duplicate()
		f.position.x = 2300
		
		var nameIndex = names.find(name)
		f.name = names[(nameIndex + 1) % 3]
		
		get_parent().add_child(f)
		
		spawned = true
		
	if position.x <= -2560:
		queue_free()
	
	position.x -= P.SPEED * delta
