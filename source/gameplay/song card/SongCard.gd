class_name SongCard extends Sprite2D

func _ready() -> void:
	Conductor.connect("new_beat", beat_hit);
	position = Vector2(-945, 360);
	
func create_songBar(song:String):
	song = song.replace("-remix", "");
	
	var path = "res://assets/images/song_cards/%s/songs/%s_card_text.png"%[SongData.week, song];
	var custom_path = {
		"monster": "-monster",
		"winter-horrorland": "-monster",
		"roses": "-roses",
		"thorns": "-thorns"
	}.get(song, "");
	
	var song_name = null;
	if ResourceLoader.exists(path, "Texture2D"):
		song_name = Sprite2D.new();
		song_name.texture = load(path);
	else:
		song_name = Label.new();
		
	var songCardPath = "res://assets/images/song_cards/%s/card_%s%s.png"%[SongData.week, SongData.week, custom_path];
	if ResourceLoader.exists(path, "Texture2D"):
		texture = load(songCardPath);
	else:
		texture = preload("res://assets/images/song_cards/tutorial/card_tutorial.png");
		
	if SongData.week == "week6":
		texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		song_name.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		
	if song_name is Label:
		var font:FontFile = preload("res://assets/fonts/vcr.ttf");
		
		song_name.text = song;
		song_name.position.x -= 30;
		song_name.add_theme_font_override("font", font);
		song_name.add_theme_color_override("font_shadow_color", Color.BLACK);
		song_name.add_theme_font_size_override("font_size", 64);
		
	add_child(song_name);
	
func beat_hit(beat):
	match beat:
		1:
			var tw = get_tree().create_tween();
			tw.tween_property(self, "position:x", 280, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		9:
			var tw = get_tree().create_tween();
			tw.tween_property(self, "position:x", -1200, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN);
			tw.tween_callback(self.queue_free);
			
