extends CanvasLayer

var opt = ["yes", "no"];
var cur_opt = 0;

var coolOffset = 550;
var offSetShit = 0;

@onready var panel = $panel;
@onready var alphabetGroup = $panel/alphabetGrp;

func _ready() -> void:
	for i in opt:
		var alphabet = Alphabet.new();
		alphabet._creat_word(i);
		alphabet.position.y = 425;
		alphabet.position.x = 330;
		alphabet.position.x += offSetShit
		alphabet.centered = true;
		alphabetGroup.add_child(alphabet);
		
		offSetShit += coolOffset;
		
	change_opt(1);
	
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && get_tree().current_scene.get("is_on_reset_menu"):
			if ev.keycode in [Global.get_key("ui_left")] && !ev.echo:
				change_opt(-1);
				
			if ev.keycode in [Global.get_key("ui_right")] && !ev.echo:
				change_opt(1);
				
			if (ev.keycode in [Global.get_key("enter")] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
				match opt[cur_opt]:
					"yes":
						SoundStuff.playAudio("confirmMenu", false);
						HighScore.clear_data();
						self.visible = false;
						
					"no":
						SoundStuff.playAudio("cancelMenu", false);
						self.visible = false;
						
func change_opt(change):
	cur_opt += change;
	cur_opt = clamp(cur_opt, 0, len(opt)-1);
	SoundStuff.add_new_sound("scrollMenu", PROCESS_MODE_INHERIT);
	
	for i in opt.size():
		alphabetGroup.get_child(i).modulate.a = 1 if i == cur_opt else 0.5;
