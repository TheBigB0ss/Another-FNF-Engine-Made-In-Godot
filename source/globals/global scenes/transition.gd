extends CanvasLayer

var stickersTimer = Timer.new();

@onready var fade_anim = $'Control/Fade_anim';
@onready var stickersGrp = $'Control/stickers';

var transition_speed = 0.65

var stickersArray = [];
var jsonStickers = {};
var sticker_textures = {};
var stickerPack = "pack1";

var can_show_stickers = true;
var deleteStickers = false;

func _ready():
	$Control.hide();
	fade_anim.speed_scale = transition_speed;
	add_child(stickersTimer);
	
	if !deleteStickers && stickersGrp.get_child_count() <= 75:
		stickersTimer.connect("timeout", spawnStickers);
		
	var jsonFile = FileAccess.open("res://assets/data/jsonSticker.json",FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	jsonStickers = jsonData.get_data();
	jsonFile.close();
	
	stickersArray = [];
	for i in jsonStickers[stickerPack]:
		for j in jsonStickers[stickerPack][i]:
			stickersArray.append(j);
			
	for i in stickersArray:
		var path = "res://assets/images/stickers/%s/%s.png"%[stickerPack, i];
		sticker_textures[i] = load(path);
		
	#print(stickersArray)
	
func _process(_delta: float) -> void:
	process_mode = 2 if get_tree().paused else 0;
	for i in stickersGrp.get_children():
		i.scale = lerp(i.scale, Vector2(1.0, 1.0), 0.90);
		
func spawnStickers():
	var count = stickersGrp.get_child_count();
	
	if deleteStickers or count > 75:
		removeStickers();
		return;
		
	if can_show_stickers:
		Sound.add_new_sound("stickerSounds/keyClick%s"%[int(randi_range(1, 8))], false);
		
	var random_sticker = stickersArray.pick_random();
	
	var sticker = Sprite2D.new();
	sticker.texture = sticker_textures[random_sticker];
	sticker.position = Vector2(randi_range(0, 1380), randi_range(0, 810));
	sticker.rotation = deg_to_rad(randi_range(-20, 20));
	sticker.scale = Vector2(1.2, 1.2);
	stickersGrp.add_child(sticker);
	
	Global.can_use_menus = stickersGrp.get_child_count() > 0;
	
func removeStickers():
	if deleteStickers && stickersGrp.get_child_count() > 0:
		if can_show_stickers:
			Sound.add_new_sound("stickerSounds/keyClick%s"%[int(randi_range(1, 8))], false);
			
		var removed_child = stickersGrp.get_child(0);
		stickersGrp.remove_child(removed_child);
		removed_child.queue_free();
		
	Global.can_use_menus = stickersGrp.get_child_count() <= 0;
	
func _is_in_transition(use_stickers):
	process_mode = 2 if get_tree().paused else 0;
	
	$Control.show();
	$Control/TransMaksDown.show();
	$Control/TransMaksUp.show();
	
	can_show_stickers = use_stickers;
	deleteStickers = false;
	stickersTimer.wait_time = 0.01;
	
	fade_anim.play("fade_in");
	
	if can_show_stickers:
		stickersGrp.show();
		stickersTimer.start();
	else:
		stickersGrp.hide();
		stickersTimer.stop();
		
func _on_fade_anim_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			fade_anim.play("fade_out");
			if get_tree().paused:
				get_tree().paused = false;
				process_mode = 0;
				
		"fade_out":
			await get_tree().create_timer(0.1).timeout
			$Control/TransMaksDown.hide();
			$Control/TransMaksUp.hide();
			
			if !can_show_stickers:
				Global.can_use_menus = true;
				
			deleteStickers = true;
