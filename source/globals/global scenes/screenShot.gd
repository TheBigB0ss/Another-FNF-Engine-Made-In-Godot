extends CanvasLayer

var screen_shot_spr = Sprite2D.new();
var timer = Timer.new();
var can_take_a_shot = true;

func _ready():
	screen_shot_spr.position = Vector2(107, 62.5);
	screen_shot_spr.scale = Vector2(0.16, 0.17);
	screen_shot_spr.modulate.a = 1;
	add_child(screen_shot_spr);
	screen_shot_spr.hide();
	
	timer.wait_time = 1;
	timer.process_mode = Node.PROCESS_MODE_ALWAYS;
	add_child(timer);
	timer.connect("timeout", hide_image);
	
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if ev.keycode in [Global.get_key("F11")] && can_take_a_shot:
				timer.start();
				screen_shot();
				exe_screen_shots();
				
func hide_image():
	var tween = get_tree().create_tween();
	tween.tween_property(screen_shot_spr, "modulate:a", 0, 0.25);
	tween.tween_callback(Callable(self, "you_can_take_a_photo"));
	
func you_can_take_a_photo():
	#if get_child_count() > 1:
	#	get_child(1).queue_free();
		
	can_take_a_shot = true;
	
func screen_shot():
	can_take_a_shot = false;
	Sound.add_new_sound("screenshot", PROCESS_MODE_ALWAYS, false);
	Flash.flashAppears(0.3);
	
	var datetime = Time.get_datetime_string_from_system(false, true).replace(":", "-");
	var screen_shot_image = get_viewport().get_texture().get_image();
	var image_name = "res://screenshots/screenshot %s.png"%[datetime];
	var texture = ImageTexture.create_from_image(screen_shot_image);
	
	screen_shot_image.save_png(image_name);
	
	var dir = DirAccess.open("res://");
	if !dir.dir_exists("screenshots"):
		dir.make_dir("screenshots");
		
	screen_shot_spr.texture = texture;
	screen_shot_spr.show();
	screen_shot_spr.modulate.a = 1;
	
func exe_screen_shots():
	var exe_path = OS.get_executable_path();
	var base_dir = exe_path.get_base_dir();
	
	var datetime = Time.get_datetime_string_from_system(false, true).replace(":", "-");
	var path = base_dir + "/screenshots/screenshot_%s.png"%[datetime];
	
	var dir = DirAccess.open(base_dir);
	if !dir.dir_exists("screenshots"):
		dir.make_dir("screenshots");
		
	var screen_shot_image = get_viewport().get_texture().get_image();
	screen_shot_image.save_png(path);
