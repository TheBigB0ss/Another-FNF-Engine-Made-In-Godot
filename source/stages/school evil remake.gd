extends Node2D

@onready var evil_tree = $tree;
@onready var evil_wall = $wall;
@onready var evil_ground = $ground;

var ground_direction = 1;
var wall_direction = 1;
var tree_direction = 1;

var move_timer = 0.0;
var move_delay = 0.05;
var opponent_time = 0.0;

var bf = null;
var gf = null;
var opponent = null;

var center = Vector2.ZERO;

func _ready() -> void:
	if Global.is_playing:
		bf = get_tree().current_scene.get("bf");
		gf = get_tree().current_scene.get("gf");
		opponent = get_tree().current_scene.get("dad");
		
		center = opponent.position;
		
func _process(delta):
	move_timer += delta;
	opponent_time += delta * 2.0;
	
	if move_timer >= move_delay:
		move_timer = 0.0;
		tree_direction = move_obj(evil_tree, 5, tree_direction, 80, 305);
		wall_direction = move_obj(evil_wall, 7, wall_direction, -25, 240);
		ground_direction = move_obj(evil_ground, 6, ground_direction, 645, 785);
		
	if !Global.is_playing:
		return;
		
	bf.position.y = evil_ground.position.y - 340;
	opponent.position = center + Vector2(
		sin(opponent_time) * 200,
		sin(opponent_time * 2) * 100
	);
	
func move_obj(obj, speed, dir, positionBegin, positionEnd):
	obj.position.y += speed * dir;
	
	if obj.position.y >= positionEnd:
		return -1;
	elif obj.position.y <= positionBegin:
		return 1;
		
	return dir;
