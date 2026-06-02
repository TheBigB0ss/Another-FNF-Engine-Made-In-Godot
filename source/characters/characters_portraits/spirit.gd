extends Sprite2D

var is_trans = false;

func reload():
	if is_trans:
		self.texture = preload("res://assets/images/portraits/characters/siit.png");
		$bow.show();
		
