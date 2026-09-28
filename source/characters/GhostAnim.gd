extends Sprite2D

func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, 0.0, 1.0 - exp(-5.0 * delta));
	
	if modulate.a <= 0.01:
		queue_free()
