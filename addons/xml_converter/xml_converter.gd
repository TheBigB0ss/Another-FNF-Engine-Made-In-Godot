@tool
extends EditorPlugin

var stuff = preload("res://addons/xml_converter/xml_panel.tscn").instantiate()

func _enter_tree() -> void:
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, stuff)

func _exit_tree() -> void:
	remove_control_from_docks(stuff)
	stuff.free()
