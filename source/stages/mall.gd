extends Node2D

func _ready():
	Global.connect("new_beat", beat_hit);
	
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if GlobalOptions.low_quality:
		$upperBop.hide();
		$bottomBop.hide();
		
func make_everyone_dance():
	$upperGuys.play("Upper Crowd Bob");
	$bottomGuys.play("Bottom Level Boppers Idle");
	$santa.play("santa idle in fear");
	
func bottomGuysHey():
	$bottomGuys.play("Bottom Level Boppers HEY!!");
	
func soakedAppears():
	return randi_range(0, 1000);
	
func beat_hit(beat):
	if beat % 2 == 0:
		make_everyone_dance();
