extends Node

var stage = 'Stage'

@onready var spotLightsGrp = $'ParallaxBackground/ParallaxLayer/spotLights';

func _ready():
	for i in 2:
		var spotLights = Sprite2D.new();
		spotLights.texture = load("res://assets/stages/week1/stage_light.png");
		spotLights.position.x = 600;
		spotLights.position.y = 750;
		spotLights.position.x += i*240;
		match i:
			0:
				spotLights.position.x = -140;
				spotLights.position.y = -110;
			1:
				spotLights.position.x = 1280;
				spotLights.position.y = -110;
				spotLights.flip_h = true;
		spotLightsGrp.add_child(spotLights)
		
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if GlobalOptions.low_quality:
		$ParallaxBackground/ParallaxLayer/curtain.hide();
		spotLightsGrp.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
