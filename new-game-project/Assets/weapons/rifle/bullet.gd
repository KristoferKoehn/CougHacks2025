extends projectile

func _ready():
	statgrabber("assaultrifle")
	start()

func _on_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	var player = area.get_parent() 
	if player.has_method("ReceiveDamage") and player.get_multiplayer_authority() != source:
		player.rpc_id(player.get_multiplayer_authority(), "ReceiveDamage", damage)
