extends Sprite2D

func _process(delta: float) -> void:
	self.modulate.a = lerp(self.modulate.a, 0.0, 0.08)
	
	if self.modulate.a <= 0:
		self.queue_free();
		
