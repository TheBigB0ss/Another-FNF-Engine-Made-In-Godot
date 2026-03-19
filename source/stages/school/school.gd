extends Node2D

func _ready():
	var tress = AnimatedBgElements.new();
	tress.new_position = Vector2(568, 448);
	tress.scale = Vector2(6.1, 6.1)
	tress.get_json("assets/stages/week6/weebTrees")
	tress.animPlay("trees_")
	$bg_trees.add_child(tress)
	
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
	else:
		$CanvasLayer.hide();
		
