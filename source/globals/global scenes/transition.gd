extends CanvasLayer

@onready var fade_anim = $'Control/Fade_anim';
@onready var stickersGrp = $'Control/stickers';
@onready var transition_anim = $Control/transition;

var stickersArray = [];
var jsonStickers = {};
var sticker_textures = {};
var stickerPack = "pack1";

var can_show_stickers = true;
var deleteStickers = false;

const max_amount = 80;

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
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
		
func _process(delta: float) -> void:
	for i in stickersGrp.get_children():
		i.scale = lerp(i.scale, Vector2(1.0, 1.0), 1.0 - exp(-12.0 * delta));
		
func spawnStickers():
	if deleteStickers:
		removeStickers();
		return;
		
	while stickersGrp.get_child_count() < max_amount:
		await get_tree().create_timer(0.015).timeout;
		if can_show_stickers:
			Sound.add_new_sound("stickerSounds/keyClick%s"%[randi_range(1, 8)]);
			
		var random_sticker = stickersArray.pick_random();
		
		var sticker = Sprite2D.new();
		sticker.texture = sticker_textures[random_sticker];
		sticker.position = Vector2(randi_range(0, 1280), randi_range(0, 720));
		sticker.rotation = deg_to_rad(randi_range(-20, 20));
		sticker.scale = Vector2(1.45, 1.45);
		stickersGrp.add_child(sticker);
		
		if stickersGrp.get_child_count() >= max_amount:
			deleteStickers = true;
			removeStickers();
			
	Global.can_use_menus = stickersGrp.get_child_count() > 0;
	
func removeStickers():
	if !deleteStickers:
		return;
		
	await get_tree().create_timer(0.19).timeout;
	
	while stickersGrp.get_child_count() > 0:
		await get_tree().create_timer(0.01).timeout;
		if can_show_stickers:
			Sound.add_new_sound("stickerSounds/keyClick%s"%[randi_range(1, 8)], false);
			
		var removed_child = stickersGrp.get_child(0);
		stickersGrp.remove_child(removed_child);
		removed_child.queue_free();
		
	Global.can_use_menus = stickersGrp.get_child_count() <= 0;
	
func _is_in_transition(use_stickers):
	transition_anim.show();
	fade_anim.play("fade_in");
	
	can_show_stickers = use_stickers;
	deleteStickers = false;
	
	if can_show_stickers:
		stickersGrp.show();
		spawnStickers();
	else:
		stickersGrp.hide();
		
func _on_fade_anim_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			Global.update_cursor("default");
			fade_anim.play("fade_out");
		"fade_out":
			await get_tree().create_timer(0.1).timeout;
			
			if !can_show_stickers:
				Global.can_use_menus = true;
				
			deleteStickers = true;
			transition_anim.hide();
