class_name ChartWindow extends Window

var mouse_inside = false;

func _ready():
	#transient = true;
	#exclusive = true;
	unresizable = true;
	minimize_disabled = true;
	maximize_disabled = true;
	
	close_requested.connect(_on_close_requested);
	
	mouse_entered.connect(func():mouse_inside = true);
	mouse_exited.connect(func():mouse_inside = false);
	
func _on_close_requested():
	hide();
	
