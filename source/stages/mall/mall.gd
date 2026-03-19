extends Node2D

func _ready():
	Conductor.connect("new_beat", beat_hit);
	
	if GlobalOptions.low_quality:
		$upperBop.hide();
		$bottomBop.hide();
		
func make_everyone_dance():
	$upperGuys.play("Upper Crowd Bob");
	$bottomGuys.play("Bottom Level Boppers Idle");
	$santa.play("santa idle in fear");
	
func bottomGuysHey():
	$bottomGuys.play("Bottom Level Boppers HEY!!");
	
func beat_hit(beat):
	if beat % 2 == 0:
		make_everyone_dance();
