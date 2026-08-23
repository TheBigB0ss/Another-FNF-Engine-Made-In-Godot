extends CharacterScript

var ghost_timer = 0.0;
func on_process(_delta):
	if GlobalOptions.low_quality:
		return;
		
	ghost_timer += _delta;
	if ghost_timer >= 0.035:
		ghost_timer = 0.0;
		creat_ghost_anim();
		
func creat_ghost_anim():
	var ghost = preload("res://source/stages/school_evil_remix/GhostAnim.tscn").instantiate();
	ghost.global_position = game.dad.global_position;
	
	var new_texture = game.dad.character.sprite_frames.get_frame_texture(game.dad.character.animation, game.dad.character.frame);
	ghost.texture = new_texture;
	ghost.offset = game.dad.character.offset;
	
	ghost.scale = game.dad.character.scale;
	ghost.flip_h = game.dad.character.flip_h;
	ghost.flip_v = game.dad.character.flip_v;
	ghost.z_index = game.dad.z_index+1;
	ghost.modulate.a = 0.7;
	add_child(ghost);
