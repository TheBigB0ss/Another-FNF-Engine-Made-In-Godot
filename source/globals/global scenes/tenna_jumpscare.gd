extends CanvasLayer

var tv_keys = [KEY_I, KEY_T, KEY_S, KEY_T, KEY_V, KEY_T, KEY_I, KEY_M, KEY_E];
var curKey = 0;
var itsTvTime = false;

@onready var tennaSpr = $Character_Sprite;
@onready var tennaAnim = $Character_Animation;

func _init():
	self.process_mode = Node.PROCESS_MODE_ALWAYS;
	self.visible = false;
	
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if !curKey > tv_keys.size()-1:
				if ev.keycode == tv_keys[curKey] && ev.keycode != KEY_BACKSPACE:
					curKey += 1;
				else:
					curKey = 0;
					
				if !curKey <= 0 && ev.keycode == KEY_BACKSPACE:
					curKey -= 1;
					
				#print(OS.get_keycode_string(tv_keys[curKey-1]).to_lower())
				#print(OS.get_keycode_string(ev.keycode).to_lower())
				
	if curKey >= tv_keys.size():
		if !Achievements.get_achievement_info("what time is it")["achievement_value"]:
			get_tree().paused = true;
			itsTvTime = true;
			self.visible = true;
			
			tennaAnim.seek(0.0);
			tennaAnim.play("ten/ ");
			curKey = 0;
			
			Global.can_use_menus = false;
			AchievementPopUp.set_achievement('what time is it', false);
			SoundStuff.add_new_sound("Tenna Jumpscare", Node.PROCESS_MODE_ALWAYS);
			MusicManager._stop_music();
			
func _process(delta):
	if itsTvTime:
		if !get_tree().paused:
			get_tree().paused = true;
			
		tennaSpr.scale = tennaSpr.scale.lerp(Vector2(1, 1), 0.0025);
		
		await get_tree().create_timer(15.14).timeout;
		tennaSpr.scale = tennaSpr.scale.lerp(Vector2(7.5, 4.5), 0.70);
		
		await get_tree().create_timer(1.05).timeout;
		Global.closeGame();
