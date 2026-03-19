extends Stage

@onready var evil_tree = $tree;
@onready var evil_wall = $wall;
@onready var evil_ground = $ground;

var ground_direction = 1;
var wall_direction = 1;
var girls_direction = 1;
var tree_direction = 1;

var move_timer = 0.0;
var move_delay = 0.05;
var dad_time = 0.0;

var ogdadPos = Vector2.ZERO;

func _ready() -> void:
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
		$Glitch.show();
	else:
		$CanvasLayer.hide();
		$Glitch.hide();
		
	ogdadPos = game.dad.position;
	
	if game.curSong == "thorns-remix" && !GlobalOptions.low_quality:
		game.opponentStrum.strumNode.visible = false;
		
	#if !GlobalOptions.low_quality or GlobalOptions.use_shader:
		#for i in range(0, 2):
			#var girl = null;
			#if i % 2 == 0:
				#girl = $girl1;
			#else:
				#girl = $girl2;
				#
			#var girls_window = Window.new();
			#girls_window.borderless = true;
			#girls_window.transparent = true;
			#girls_window.transient = false;
			#girls_window.always_on_top = true;
			#girls_window.size = Vector2(210, 435);
			#girls_window.position = Vector2(80 + i * 1550, 390);
			#add_child(girls_window);
			#
			#var new_girl = Sprite2D.new();
			#new_girl.texture = girl.texture;
			#new_girl.material = girl.material;
			#new_girl.scale = girl.scale;
			#new_girl.texture_filter = girl.texture_filter;
			#new_girl.position = girls_window.size / 2;
			#new_girl.centered = true;
			#girls_window.add_child(new_girl);
			#
			#girls_window.show();
			
var ghost_timer = 0.0
var time = 0.0
func _process(delta: float) -> void:
	move_timer += delta;
	dad_time += delta * 2.0;
	
	if game.curSong == "thorns-remix":
		time += delta * 3;
		for i in game.opponentStrum.strumNode.get_child_count():
			var note = game.opponentStrum.strumNode.get_child(i);
			note.position = Vector2(400 + cos(time + i * 0.8) * 200, 300 + sin((time + i * 0.8)*2) * 100);
			
		for i in game.playerStrum.strumNode.get_child_count():
			var note = game.playerStrum.strumNode.get_child(i);
			note.position.y = lerp(note.position.y, (note.strum_positions.y + note.strum_offsets.y + sin(time + i * 0.5) * 50), 0.1)
			
	if move_timer >= move_delay:
		move_timer = 0.0;
		tree_direction = move_obj(evil_tree, 5, tree_direction, 80, 305);
		wall_direction = move_obj(evil_wall, 7, wall_direction, -25, 240);
		ground_direction = move_obj(evil_ground, 6, ground_direction, 645, 785);
		
	game.bf.position.y = evil_ground.position.y - 340;
	game.dad.position = ogdadPos + Vector2(sin(dad_time) * 200,sin(dad_time * 2) * 100);
	
	if !GlobalOptions.low_quality:
		ghost_timer += delta;
		if ghost_timer >= 0.04:
			ghost_timer = 0.0;
			creat_ghost_anim();
			
func move_obj(obj, speed, dir, positionBegin, positionEnd):
	obj.position.y += speed * dir;
	
	if obj.position.y >= positionEnd:
		return -1;
	elif obj.position.y <= positionBegin:
		return 1;
		
	return dir;
	
func creat_ghost_anim():
	if !is_instance_valid(game.dad):
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
