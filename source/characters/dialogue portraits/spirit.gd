extends Sprite2D

var is_trans = false;

func _process(delta):
	if is_trans:
		$bow.show();
	else:
		$bow.hide();
