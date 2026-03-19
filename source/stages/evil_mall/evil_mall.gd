extends Stage

#you know what, fuck this cutscene
func winterHorrorland_cutscene():
	set_hud(false);
	SongData.is_not_in_cutscene = false;
	Global.is_on_video = true;
	
	var camera = get_tree().current_scene.get("sectionCamera");
	camera.position = %tree_pos.position;
	camera.zoom = Vector2(1.395, 1.395);
	
	Flash.just_appear(0.5, Color(0.0, 0.0, 0.0));
	
	await get_tree().create_timer(0.5).timeout
	Sound.playAudio("Lights_Turn_On", false);
	
	await get_tree().create_timer(1.8).timeout
	camera.zoom = lerp(camera.zoom, Vector2(0.8, 0.8), 0.9);
	camera.position = Vector2(565, 610);
	
	await get_tree().create_timer(0.8).timeout
	start_song();
	
func set_hud(is_visible):
	var strums = get_tree().current_scene.get("game_strums")
	var hud = get_tree().current_scene.get("hud");
	strums.visible = is_visible;
	hud.visible = is_visible;
	
func start_song():
	set_hud(true);
	MusicManager._stop_music();
	SongData.is_not_in_cutscene = true;
	Global.is_on_video = false;
	Global.emit_signal("end_tankman_cutscene");
	
var ghost_timer = 0.0;
func _process(delta: float) -> void:
	if !GlobalOptions.low_quality:
		ghost_timer += delta;
		if ghost_timer >= 0.04:
			ghost_timer = 0.0;
			creat_ghost_anim();
			
func creat_ghost_anim():
	if !is_instance_valid(game.dad) && game.dad.curCharacter != "monsterChristmas":
		return;
		
	var ghost = preload("res://source/stages/school_evil_remix/GhostAnim.tscn").instantiate();
	ghost.global_position = game.dad.global_position;
	if game.dad.character is AnimatedSprite2D:
		var new_texture = game.dad.character.sprite_frames.get_frame_texture(game.dad.character.animation, game.dad.character.frame);
		ghost.texture = new_texture;
		ghost.offset = game.dad.character.offset;
		
	if game.dad.character is Sprite2D:
		ghost.texture = game.dad.character.texture;
		ghost.region_enabled = game.dad.character.region_enabled
		ghost.region_rect = game.dad.character.region_rect
		
	ghost.scale = game.dad.character.scale;
	ghost.flip_h = game.dad.character.flip_h;
	ghost.flip_v = game.dad.character.flip_v;
	ghost.z_index = game.dad.z_index+1;
	ghost.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
	ghost.modulate.a = 0.7;
	add_child(ghost);
