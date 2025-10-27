extends AnimatedSprite2D

func cool_splash(data, noteData, dir, strumX, strumY):
	self.position = Vector2(strumX, strumY);
	play("%s%s"%[dir, data]);
	
func _on_animation_finished() -> void:
	self.queue_free();
	
	var splashes = get_tree().current_scene.get("note_splshes");
	for i in splashes.get_children():
		splashes.remove_child(i);
		i.queue_free();
