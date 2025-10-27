extends Node2D

func _ready():
	var tress = AnimatedBgElements.new();
	tress.new_position = Vector2(568, 448);
	tress.scale = Vector2(6.1, 6.1)
	tress.get_json("assets/stages/week6/weebTrees")
	tress.animPlay("trees_")
	$bg_trees.add_child(tress)
	
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
	else:
		$CanvasLayer.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
