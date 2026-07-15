extends Node

var bpm = 100;

var getSongTime = 0;
var songSpeed = 0.0;
var song_mult = 1;

var crochet = (60.0 / bpm) * 1000.0;
var stepCrochet = crochet / 4;

var lastBeat = -1;
var lastStep = -1;
var lastSection = -1;

var curBeat = 0;
var curStep = 0;
var curSection = 0;

var startTime = 0;
var seekTime = 0;

var bpmChangeMap = [];

signal new_beat(beat);
signal new_step(step);
signal change_section(section);

func _process(_delta):
	var last_change = [0, 0.0, bpm];
	for i in bpmChangeMap:
		if getSongTime >= i[1]:
			last_change = i;
		else:
			break;
			
	crochet = (60.0 / last_change[2]) * 1000.0;
	stepCrochet = crochet / 4;
	
	curStep = last_change[0] + floor((getSongTime - last_change[1]) / stepCrochet);
	curBeat = floor(curStep / 4);
	curSection = int(floor(curStep/16));
	
	if curSection >= SongData.songSections.size() && !SongData.songSections.is_empty():
		return;
		
	if lastSection != curSection:
		lastSection = curSection;
		changeSection();
		
	if lastBeat != curBeat:
		lastBeat = curBeat;
		beatHit();
		
	if lastStep != curStep:
		lastStep = curStep;
		stepHit();
		
func stepHit():
	self.emit_signal("new_step", int(curStep));
	#print("new step: "+str(curStep))
	
func beatHit():
	self.emit_signal("new_beat", int(curBeat));
	#print("new beat: "+str(curBeat))
	
func changeSection():
	self.emit_signal("change_section", int(curSection));
	#print("new section: "+str(curSection))
	
func changeBpm(newBpm):
	if newBpm != 0 or newBpm > 0:
		bpm = newBpm;
		crochet = (60.0 / bpm) * 1000.0;
		stepCrochet = crochet / 4;
		
func reset():
	if bpm <= 0:
		bpm = 100;
		
	lastStep = -1;
	lastBeat = -1;
	lastSection = -1;
	
	curBeat = 0;
	curStep = 0;
	curSection = 0;
	
	crochet = (60.0 / bpm) * 1000.0;
	stepCrochet = crochet / 4.0;
	getSongTime = 0;
	
	seekTime = 0;
	
func mapBPMChanges():
	bpmChangeMap.clear();
	
	var curBPM = SongData.songBpm;
	var totalSteps = 0;
	var totalPos = 0.0;
	
	#bpmChangeMap.append([0, 0.0, curBPM]);
	
	for section in SongData.songSections:
		if section["changeBPM"]:
			curBPM = section["bpm"];
			bpmChangeMap.append([totalSteps, totalPos, curBPM]);
			
		var sectionLength = section["lengthInSteps"];
		totalSteps += sectionLength;
		totalPos += ((60.0 / curBPM) * 1000.0 / 4.0) * sectionLength;
		
func update_position(time):
	getSongTime = time;
	var last_change = [0, 0.0, bpm];
	for i in bpmChangeMap:
		if time >= i[1]:
			last_change = i;
		else:
			break;
			
	crochet = (60.0 / last_change[2]) * 1000.0;
	stepCrochet = crochet / 4;
	
	curStep = last_change[0] + floor((time - last_change[1]) / stepCrochet);
	curBeat = floor(curStep / 4);
	
	if curSection >= SongData.songSections.size() && !SongData.songSections.is_empty():
		return;
		
	curSection = int(floor(curStep / 16));
	
	lastStep = curStep;
	lastBeat = curBeat;
	lastSection = curSection;
