extends CanvasLayer

@onready var coolvideo = $VideoStreamPlayer;

func _ready():
	var alphabet = Alphabet.new();
	alphabet._creat_word("press enter to skip");
	#$alphabetGrp.add_child(alphabet);
	
func set_video(volume, loop, video, video_scale):
	coolvideo.stream = load("res://assets/videos/%s.ogv"%[video]);
	coolvideo.loop = loop;
	coolvideo.volume_db = volume;
	coolvideo.scale = Vector2(video_scale[0], video_scale[1])
	coolvideo.play();
	$alphabetGrp.show();
	
	Global.is_on_video = true;
	
func stop_video():
	coolvideo.stop();
	$alphabetGrp.hide();
	
#func _process(delta):
	#if Input.is_action_just_pressed("ui_accept"):
		#if Global.is_on_video:
			#stop_video();
			#Global.is_on_video = false;
			#Global.emit_signal("end_cutscene");
			
func _on_video_stream_player_finished() -> void:
	$alphabetGrp.hide();
	Global.is_on_video = false;
	Global.emit_signal("end_cutscene");
