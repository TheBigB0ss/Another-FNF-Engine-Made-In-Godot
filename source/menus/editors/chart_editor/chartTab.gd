extends Control

@export var mainScene:Node2D;

@onready var fileTab = $file
@onready var helpTab = $help;
@onready var chartTab = $chart;
@onready var previewTab = $preview;

func onFilePress(id):
	match id:
		0:
			mainScene.loadJson(%song_name.text, %song_difficulty.text);
			
			%Bpm.value = SongData.songBpm;
			%is_pixel_stage.button_pressed = SongData.isPixelStage;
			%song_speed.value = SongData.songSpeed;
			
			mainScene.changeSection(0);
			Conductor.reset();
			Conductor.changeBpm(SongData.songBpm);
			
			mainScene.load_section();
			mainScene.is_playing = false;
			mainScene.set_audio();
		1:
			mainScene.cool_file_save.popup_centered();
		2:
			mainScene.cool_events_save.popup_centered();
			
func onHelpPress(id):
	match id:
		0:
			$helpWindow.popup();
		1:
			$soundWindow.popup();
			
func onChartPress(id):
	match id:
		0:
			$chartWindow.popup();
		1:
			$sectionWindow.popup();
		2:
			$notesWindow.popup();
		3:
			$eventsWindow.popup();
			
func onPreviewPress(id):
	match id:
		0:
			$opponentPreviewWindow.popup();
		1:
			$playerPreviewWindow.popup();
			
func _ready():
	fileTab.get_popup().add_item("open file", 0);
	fileTab.get_popup().add_item("save file", 1);
	fileTab.get_popup().add_item("save events", 2);
	
	helpTab.get_popup().add_item("about", 0);
	helpTab.get_popup().add_item("sfx", 1);
	
	chartTab.get_popup().add_item("song meta", 0);
	chartTab.get_popup().add_item("section meta", 1);
	chartTab.get_popup().add_item("notes", 2);
	chartTab.get_popup().add_item("events", 3);
	
	previewTab.get_popup().add_item("opponent preview", 0);
	previewTab.get_popup().add_item("player preview", 1);
	
	fileTab.get_popup().id_pressed.connect(onFilePress);
	helpTab.get_popup().id_pressed.connect(onHelpPress);
	chartTab.get_popup().id_pressed.connect(onChartPress);
	previewTab.get_popup().id_pressed.connect(onPreviewPress);
	
var old_song_text = ".";
var old_diff_text = ".";
func _process(_delta: float) -> void:
	if old_song_text != %song_name.text && old_diff_text != %song_difficulty.text:
		fileTab.get_popup().set_item_text(0, "open file: %s/%s"%[%song_name.text, %song_difficulty.text]);
		
		old_song_text = %song_name.text;
		old_diff_text = %song_difficulty.text;
		
