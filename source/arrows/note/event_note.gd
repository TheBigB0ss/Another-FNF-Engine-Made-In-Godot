class_name EventNote extends Note

var event_note:Sprite2D;
func _ready():
	self.scale = Vector2(0.25, 0.25);
	
	event_note = Sprite2D.new();
	event_note.texture = preload("res://assets/images/arrows/event_note.png");
	event_note.flip_h = true;
	add_child(event_note);
	
	
