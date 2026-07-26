extends Node2D

var selectionRect = Rect2();
var mouseBoxPos = Vector2.ZERO;
var isHolding = false;

func _draw() -> void:
	if !isHolding:
		return;
		
	draw_rect(selectionRect, Color(0.513, 0.908, 1.0, 0.3));
	draw_rect(selectionRect, Color(0.307, 0.711, 0.805, 0.5), false, 2.0);
	
func _input(ev):
	if ev is InputEventMouseMotion:
		if isHolding:
			selectionRect = Rect2(
				min(mouseBoxPos.x, to_local(get_global_mouse_position()).x),
				min(mouseBoxPos.y, to_local(get_global_mouse_position()).y),
				max(mouseBoxPos.x, to_local(get_global_mouse_position()).x) - min(mouseBoxPos.x, to_local(get_global_mouse_position()).x),
				max(mouseBoxPos.y, to_local(get_global_mouse_position()).y) - min(mouseBoxPos.y, to_local(get_global_mouse_position()).y)
			);
			queue_redraw();
			
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				isHolding = true;
				mouseBoxPos = to_local(get_global_mouse_position());
				queue_redraw();
			else:
				isHolding = false;
				selectionRect = Rect2();
				queue_redraw();
				
func obj_inside_block(obj, offset):
	if obj == null:
		return false;
		
	if !obj is Sprite2D:
		return false;
		
	var size = obj.texture.get_size() * obj.scale;
	if (selectionRect.position.x + selectionRect.size.x > obj.global_position.x - size.x / offset && selectionRect.position.x < obj.global_position.x + size.x / offset  && selectionRect.position.y + selectionRect.size.y > obj.global_position.y - size.y / offset  && selectionRect.position.y < obj.global_position.y + size.y / offset):
		return true;
		
	return false;
