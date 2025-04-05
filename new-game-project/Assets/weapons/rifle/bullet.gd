extends projectile

func _ready():
	statgrabber("assaultrifle")
	start()

func _on_timer_timeout() -> void:
	queue_free()
