extends Area3D

func _ready():
	body_entered.connect(collided)

func collided(area: Node3D):
	if area.name == "Player":
		area.set_checkpoint()
