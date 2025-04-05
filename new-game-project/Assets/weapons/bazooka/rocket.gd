extends projectile

func _ready():
	statgrabber("bazooka")
	start()

func _on_timer_timeout() -> void:
	queue_free()
