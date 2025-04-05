extends projectile

func _ready():
	statgrabber("diskshooter")
	start()

func _on_timer_timeout() -> void:
	queue_free()
