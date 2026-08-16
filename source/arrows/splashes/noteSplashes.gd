extends AnimatedSprite2D

func play_splash(strumX, strumY, anim):
	position = Vector2(strumX, strumY);
	
	offset.y = -70.0 if anim.contains("holdCover") else 0.0;
	if anim.contains("pixel"):
		texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		scale = Vector2.ONE*4.5;
	else:
		scale = Vector2.ONE * (0.55 if anim.contains("holdCover") or anim.contains("finishCover") else 0.9);
		
	play(anim);
	
func _on_animation_finished() -> void:
	if animation.contains("hold"):
		return;
		
	self.queue_free();
	
