extends Node2D

func _ready():
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
	else:
		$CanvasLayer.hide();
		
