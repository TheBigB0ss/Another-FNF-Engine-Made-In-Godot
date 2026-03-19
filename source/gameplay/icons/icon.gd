class_name Icon extends Sprite2D

func _ready() -> void:
	Conductor.new_beat.connect(beat_hit);
	
func _process(delta: float) -> void:
	self.scale = lerp(self.scale, Vector2(1.0, 1.0), 0.08);
	
func play_icon_anim(anim):
	if self.texture.get_width() > 150:
		match anim:
			"win":
				if self.texture.get_width() <= 300:
					self.frame = 0;
				elif self.texture.get_width() >= 450:
					self.frame = 2;
			"lose":
				self.frame = 1;
			"idle":
				self.frame = 0;
	else:
		self.frame = 0;
		
func set_icon_hframes():
	if self.texture.get_width() <= 300:
		self.hframes = 2;
	if self.texture.get_width() >= 450:
		self.hframes = 3;
	if self.texture.get_width() <= 150:
		self.hframes = 1;
		
func beat_hit(beat):
	if GlobalOptions.updated_icon == "disabled":
		return;
		
	self.scale = Vector2(1.25, 1.25);
	
func reload_icon(icon):
	self.texture = load("res://assets/images/icons/icon-%s.png"%[icon]);
	set_icon_hframes();
	
