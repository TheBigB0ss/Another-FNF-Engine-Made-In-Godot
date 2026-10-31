extends CharacterScript

var ghost_timer = 0.0;
func on_process(_delta):
	if Engine.is_editor_hint():
		return;
		
	if GlobalOptions.low_quality or game == null:
		return;
		
	#ghost_timer += _delta;
	#if ghost_timer >= 0.05:
	#	creat_ghost_anim();
	#	ghost_timer = 0.0;
		
func creat_ghost_anim():
	var ghost = preload("res://source/characters/GhostAnim.tscn").instantiate();
	var character = game.dad.character;
	
	var anim_name = character.animations[character.animation];
	var frame_data = character.get_frame_info(anim_name);
	
	if frame_data.is_empty():
		return;
		
	ghost.global_position = game.dad.global_position;
	ghost.texture = character.texture;
	ghost.region_enabled = true;
	ghost.region_rect = Rect2(
		frame_data["x"],
		frame_data["y"],
		frame_data["width"],
		frame_data["height"]
	);
	
	ghost.material = character.material;
	ghost.offset = character.offset;
	ghost.texture_filter = character.texture_filter;
	ghost.scale = character.scale;
	ghost.flip_h = character.flip_h;
	ghost.flip_v = character.flip_v;
	ghost.z_index = game.dad.z_index + 1;
	ghost.modulate.a = 0.7;
	
	add_child(ghost);
	
