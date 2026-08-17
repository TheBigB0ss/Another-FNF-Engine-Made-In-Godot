@tool
class_name AtlasSprite extends Node2D

var spriteStuff = {};

@export_dir var path = "":
	set(value):
		path = value;
		spriteStuff = {
			"sprite": "%s/spritemap1.png"%[path],
			"animation": "%s/Animation.json"%[path],
			"spriteMap": "%s/spritemap1.json"%[path]
		};
		reload();
		
@export_range(0.1, 5.0, 0.001) var speed = 1.0;
@export var frame = 0;
@export var playing = true;
@export var loop = false;
@export var limit = 0;
@export var start_frame = 0;
@export var animate_symbols = false;

@export var flip_h = false;
@export var flip_v = false;

var atlas = {};
var animationData = {};
var spriteData = {};
var symbol_data = {};
var symbols_elements = {};

var total_frames = 0;
var spriteZIndex = 0;

var animation = 0:
	set(value):
		animation = value;
		if !animationList.is_empty():
			play(animationList[animation]);
			
var animationList = [];

func reload():
	total_frames = 0;
	spriteZIndex = 0;
	symbols_elements.clear();
	symbol_data.clear();
	animationData.clear();
	spriteData.clear();
	atlas.clear();
	animationList.clear();
	animationList.append("NONE");
	
	for i in self.get_children():
		i.queue_free();
		self.remove_child(i);
		
	animationData = getJsonData(spriteStuff["animation"]);
	spriteData = getJsonData(spriteStuff["spriteMap"]);
	
	for i in spriteData["ATLAS"]["SPRITES"]:
		var frameData = i["SPRITE"];
		atlas[i["SPRITE"]["name"]] = {
			"sprite_rect": Rect2(
				frameData["x"],
				frameData["y"],
				frameData["w"],
				frameData["h"]
			),
			"sprite_rotated": frameData["rotated"]
		};
		
	for i in animationData["AN"]["TL"]["L"]:
		for fr in i.get("FR", []):
			total_frames = max(total_frames, fr["I"] + fr["DU"]);
			
			var animName = fr.get("N", "");
			if !animationList.has(animName) && animName != "":
				animationList.append(animName);
				
	for i in animationData["SD"]["S"]:
		symbol_data[i["SN"]] = i;
		
	notify_property_list_changed();
	
func draw_symbol(element, layer, index, elementTransform, key = "atlas"):
	var elementData = element.get("SI", element.get("ASI"));
	var symbolID = symbol_data[elementData["SN"]];
	var keyID = "%s/%s/%d"%[key, symbolID["SN"], index];
	
	var trans = Transform2D.IDENTITY;
	if elementData.has("M3D"):
		var m = elementData["M3D"];
		trans = Transform2D(
			Vector2(m[0], m[1]),
			Vector2(m[4], m[5]),
			Vector2(m[12], m[13])
		);
		
	elif elementData.has("MX"):
		var m = elementData["MX"];
		trans = Transform2D(
			Vector2(m[0], m[1]),
			Vector2(m[2], m[3]),
			Vector2(m[4], m[5])
		);
		
	var finalTrans = elementTransform*trans;
	
	var symbol_frame = int(elementData.get("FF", 0));
	var symbol_total_frames = 0;
	
	for l in symbolID["TL"].get("L", []):
		for fr in l.get("FR", []):
			symbol_total_frames = max(symbol_total_frames, int(fr["I"]) + int(fr["DU"]));
			
	var ff = int(elementData.get("FF", 0));
	match elementData.get("LP", "SF"):
		"LP":
			if animate_symbols:
				symbol_frame = wrapi(ff + (frame - start_frame), 0, symbol_total_frames);
		"PO":
			if animate_symbols:
				symbol_frame = min(ff + (frame - start_frame), int(elementData.get("LF", ff)));
		"SF":
			symbol_frame = ff;
		_:
			symbol_frame = ff;
			
	var symbolLayers = symbolID["TL"].get("L", []).duplicate();
	symbolLayers.reverse();
	
	for i in symbolLayers:
		for fr in i.get("FR", []):
			var fr_start = int(fr["I"]);
			var fr_end = fr_start + int(fr["DU"]);
			
			if symbol_frame >= fr_start && symbol_frame < fr_end:
				var newId = 0;
				
				for e in fr.get("E", []):
					var data = e.get("SI", e.get("ASI"));
					if data.has("N"):
						create_sprite(data, keyID, newId, finalTrans);
						
					elif data.has("SN"):
						draw_symbol(e, layer, newId, finalTrans, keyID);
						
					newId += 1;
					
func create_sprite(data, keyID, index, spriteTransform):
	var id = "%s/%s"%[keyID, data["N"]];
	
	var imgId = data["N"];
	var rect = atlas[imgId]["sprite_rect"];
	var rotated = atlas[imgId]["sprite_rotated"];
	
	if !symbols_elements.has(id):
		var symbolSprite = Sprite2D.new();
		symbolSprite.centered = false;
		symbolSprite.name = id;
		add_child(symbolSprite);
		symbols_elements[id] = symbolSprite;
		
	var spr = symbols_elements[id];
	spr.visible = true;
	
	var textureFrame = AtlasTexture.new();
	textureFrame.atlas = load(spriteStuff["sprite"]);
	textureFrame.region = rect;
	textureFrame.region = rect;
	
	spr.texture = textureFrame;
	
	var trans = Transform2D.IDENTITY;
	if data.has("M3D"):
		var m = data["M3D"];
		trans = Transform2D(
			Vector2(m[0], m[1]),
			Vector2(m[4], m[5]),
			Vector2(m[12], m[13])
		);
		
	elif data.has("MX"):
		var m = data["MX"];
		trans = Transform2D(
			Vector2(m[0], m[1]),
			Vector2(m[2], m[3]),
			Vector2(m[4], m[5])
		);
		
	var finalTrans = spriteTransform * trans;
	
	if rotated:
		var rotatedTransform = Transform2D(deg_to_rad(-90.0),Vector2(0, rect.size.x));
		finalTrans = finalTrans * rotatedTransform;
		
	spr.transform = finalTrans;
	spr.z_index = spriteZIndex;
	spriteZIndex += 1;
	
func _process(delta: float) -> void:
	atlas_process(delta);
	
var timer = 0.0;
func atlas_process(delta: float) -> void:
	scale.x = abs(scale.x) * (-1 if flip_h else 1);
	scale.y = abs(scale.y) * (-1 if flip_v else 1);
	
	if animationData.is_empty():
		return;
		
	if playing:
		timer += delta * animationData["MD"]["FRT"] * (speed if speed != null else 1.0);
		
		var loopLimit = limit if limit > 0 else total_frames;
		if timer > loopLimit:
			timer = start_frame if loop else loopLimit;
			
		frame = int(timer);
		
	frame = (
		wrapi(frame, 0, total_frames - 1) if loop else clamp(frame, 0, total_frames - 1) if (limit == null or limit == 0) else wrapi(frame, 0, limit) if loop else clamp(frame, 0, limit)
	);
	
	spriteZIndex = 0;
	
	for i in symbols_elements.keys():
		symbols_elements[i].visible = false;
		#symbols_elements[i].queue_free();
		
	#symbols_elements.clear();
	
	var layers = animationData["AN"]["TL"]["L"].duplicate();
	layers.reverse();
	
	for i in range(layers.size()):
		var layer = layers[i];
		
		for fr in layer.get("FR", []):
			if frame >= fr["I"] && frame < fr["I"] + fr["DU"]:
				var id = 0;
				for e in fr.get("E", []):
					draw_symbol(e, i, id, Transform2D.IDENTITY);
					id += 1;
					
func getJsonData(data):
	var new_animationFile = FileAccess.open(data, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(new_animationFile.get_as_text());
	new_animationFile.close();
	
	return jsonData.get_data();
	
func play(anim):
	if anim == " " or anim == "" or anim == "NONE":
		start_frame = 0;
		timer = 0;
		frame = 0;
		limit = 0;
		
		return;
		
	playing = true;
	for j in animationData["AN"]["TL"]["L"]:
		for k in j["FR"]:
			if k.get("N", "") == anim:
				start_frame = int(k["I"]);
				timer = float(k["I"]);
				frame = k["I"];
				limit = (k["I"] + k["DU"])-1;
				
func _get_property_list():
	var properties: Array[Dictionary] = [];
	
	properties.append({
		"name": "animation",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(animationList),
		"usage": PROPERTY_USAGE_DEFAULT
	});
	
	return properties;
