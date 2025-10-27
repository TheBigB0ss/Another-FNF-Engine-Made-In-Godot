extends CanvasLayer

var flash = ColorRect.new();

func _ready() -> void:
	flash.size = Vector2(1280, 720);
	flash.modulate.a = 0;
	add_child(flash);
	
func flashAppears(flashTime = 0.5, color = Color(255, 255, 255)):
	flash.modulate.a = 1;
	flash.color = color;
	
	var tween = get_tree().create_tween()
	tween.tween_property(flash, "modulate:a", 0, flashTime);
	
func just_appear(timer = 0.0, color = Color(255, 255, 255)):
	flash.modulate.a = 1;
	flash.color = color;
	
	await get_tree().create_timer(timer).timeout
	flash.modulate.a = 0;
