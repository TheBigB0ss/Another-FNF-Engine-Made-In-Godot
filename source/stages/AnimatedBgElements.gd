class_name AnimatedBgElements extends AnimatedSprite2D

var anim_name = [];
var indices = [];
var new_position = Vector2();

func _ready():
	self.position = new_position;
	
func get_json(elementJson):
	var element_status = {}
	
	var frames = SpriteFrames.new();
	frames.remove_animation("default")
	
	var jsonFile = FileAccess.open("res://%s.json"%[elementJson], FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	element_status = jsonData.get_data();
	jsonFile.close();
	
	if element_status["is pixel sprite"]:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
		
	var itens_count = 0;
	for i in element_status["anims"]:
		var sprite = AtlasTexture.new();
		sprite.atlas = load("res://%s.png"%[elementJson]);
		
		anim_name.append(element_status["anims"][itens_count]["name"].substr(0, len(element_status["anims"][itens_count]["name"])-4));
		indices.append(element_status["anims"][itens_count]["indices"]);
		
		sprite.region = Rect2(
			Vector2(indices[itens_count][0], indices[itens_count][1]),
			Vector2(indices[itens_count][2], indices[itens_count][3])
		);
		
		var new_anim = "";
		for k in anim_name:
			new_anim = k;
			
		if !frames.has_animation(new_anim):
			frames.add_animation(new_anim);
			frames.set_animation_loop(new_anim, element_status["loop"]);
			frames.set_animation_speed(new_anim, element_status["speed"]);
		frames.add_frame(new_anim, sprite);
		
		itens_count += 1;
		
	sprite_frames = frames;
	if element_status["create .res"]:
		ResourceSaver.save(frames, "res://%s.res"%[elementJson], ResourceSaver.FLAG_COMPRESS)
		
var cur_anim = ""
func animPlay(anim):
	play(anim)
	
	cur_anim = anim;
