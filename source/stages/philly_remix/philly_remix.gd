extends Stage

@onready var darnell = $'characters/Darnell';
@onready var nene = $'characters/Nene';

@onready var darnellStrum = $strums/DarnellStrum;
@onready var neneStrum = $strums/NeneStrum;
@onready var strums = $strums;

var colorArray = [];
var buddys_data = {};
var buddys_array = [];

var itsBuddysPart = false;
var buddyTarget = null;

var colors = {
	"red": Color("#FD4531"),
	"blue": Color("#31A2FD"),
	"green": Color("#31FD8C"),
	"orange": Color("#FBA633"),
	"pink": Color("#FB33F5")
};

func _ready():
	if game.curSong != "blammed-remix" && game.songDiff == "remix":
		darnell.hide();
		nene.hide();
		
	if SongData.isPlaying:
		if game.curSong == "philly-nice-remix" && game.songDiff == "remix":
			for i in [darnellStrum, neneStrum]:
				if GlobalOptions.down_scroll:
					i.position.y = 885;
				i.enable = true;
				i.pressed_note.connect(note_pressed);
				
	for i in colors.keys():
		colorArray.append(i);
		
	set_color();
	
func _process(delta):
	if itsBuddysPart:
		game.opponentStrum.position.x = lerp(game.opponentStrum.position.x, -850.0, 0.05);
		
		call_func("cam_follow_poses", [darnell]);
		call_func("cam_follow_poses", [nene]);
		
	if buddyTarget == null:
		buddyTarget = darnell;
		
var lastColor = null;
func set_color():
	var newColor = colorArray.pick_random();
	
	while newColor == lastColor:
		newColor = colorArray.pick_random();
		
	lastColor = newColor;
	
	$lights.modulate = colors[newColor];
	$lights.modulate.a = 1;
	
	var tw = get_tree().create_tween();
	tw.tween_property($lights, "modulate:a", 0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func beat_hit(beat) -> void:
	if beat % 4 == 0:
		set_color();
		
	if game.curSong == "philly-nice-remix" && game.songDiff == "remix":
		match beat:
			260:
				$ColorRect.show();
			268:
				strums.show();
				itsBuddysPart = true;
				$ColorRect.hide();
				nene.show();
				darnell.show();
				funny_guy();
				
func step_hit(step) -> void:
	if SongData.isPlaying:
		if itsBuddysPart && game.curSong == "philly-nice-remix" && game.songDiff == "remix":
			if game.camera_on_Bf:
				game.cam_target = game.bf
			else:
				game.cam_target = buddyTarget;
				
			if game.sectionCamera != null && SongData.isPlaying:
				call_func("move_cam", [true if GlobalOptions.updated_cam == "smooth" else false, (game.cam_target.global_position + Vector2(game.cam_target.camera_pos[0], game.cam_target.camera_pos[1]))]);
				
func funny_guy():
	darnell._playAnim("singLaugh");
	nene._playAnim("singLaugh");
	
func custom_strum_anim(noteID, strum, timer):
	strum.get_child(noteID).reset_arrow_anim = timer;
	strum.get_child(noteID).play_note_anim("confirm");
	
func note_pressed(char):
	game.iconP2.texture = load("res://assets/images/icons/icon-%s.png"%[char.curIcon]);
	game.healthBar.tint_under = Color("#ff000f") if GlobalOptions.updated_hud == "classic hud" else char.healthBar_Color;
