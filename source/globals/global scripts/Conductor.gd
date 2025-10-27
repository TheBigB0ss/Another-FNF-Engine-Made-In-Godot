extends Node

var bpm = 100;

var getMusicTime = 0;
var getSongTime = 0;
var songSpeed = 0.0;
var song_mult = 1;

var crochet = ((60 / float(bpm)) * 1000);
var stepCrochet = crochet / 4;

var lastBeat = 0;
var lastStep = 0;

var curBeat = 0;
var curStep = 0;

var bpmChangeMap = [];

func _process(delta):
	var last_change = [0, 0, 0];
	for i in bpmChangeMap:
		if getSongTime >= i[1]:
			last_change = i
			
	curStep = last_change[0] + floor((getSongTime - last_change[1]) / stepCrochet);
	curBeat = floor(curStep / 4);
	
	if lastBeat < curBeat && curBeat > lastBeat:
		lastBeat = curBeat;
		beatHit();
		
	if lastStep < curStep && curStep > lastStep:
		lastStep = curStep;
		stepHit();
		
func stepHit():
	Global.emit_signal("new_step", int(curStep));
	#print("new step: "+str(curStep))
	
func beatHit():
	Global.emit_signal("new_beat", int(curBeat));
	#print("new beat: "+str(curBeat))
	
func changeBpm(newBpm):
	if newBpm != 0 or newBpm > 0:
		bpm = newBpm;
		crochet = (60 / float(bpm)) * 1000;
		stepCrochet = crochet / 4;
		
func reset():
	curStep = 0;
	curBeat = 0;
	crochet = ((60 / bpm) * 1000);
	stepCrochet = crochet / 4;
	
func mapBPMChanges(songJson):
	bpmChangeMap = [];
	
	var curBPM = songJson["song"]["bpm"];
	var totalSteps = 0;
	var totalPos = 0;
	
	var cur_shit = 0;
	for i in songJson["song"]["notes"]:
		if i["changeBPM"] == true:
			curBPM = i["bpm"];
			bpmChangeMap.insert(cur_shit, [totalSteps, totalPos, i["bpm"]]);
			cur_shit += 1;
			
		var sectionLenght = i["lengthInSteps"];
		totalSteps += sectionLenght;
		totalPos += ((60 / curBPM) * 1000 / 4) * sectionLenght;
