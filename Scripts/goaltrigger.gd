extends Area3D

func _on_body_entered(body:Node3D):
	if body.name == "GolfBall":
		var player = body.get_parent()
		player.win()
