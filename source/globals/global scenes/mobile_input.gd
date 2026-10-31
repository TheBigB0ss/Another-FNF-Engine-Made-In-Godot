extends CanvasLayer

@onready var controlls = $Controlls
@onready var otherKeys = controlls.get_node("Others")
@onready var notesKeys = controlls.get_node("Notes")

@onready var input_map:Dictionary[Node, PackedStringArray] = {
	%Esc: ["escape"],
	%Enter: ["enter"],
	
	%Left: ["left"],
	%Down: ["down"],
	%Up: ["up"],
	%Right: ["right"]
}

var simulateNote:bool = false
var draged = false
var touchDelay = 0.

var touched = false
var use_notes = false:set=update_note_visibility

const MIN_DRAG_SPD = 2.

var click_in_button = false

var touches = {};
var reset_touch_active = false;

func _ready() -> void:
	if !Global.is_on_mobile:
		self.visible = false;
		return;
		
	use_notes = false
	
	for inp in input_map:
		if inp is TouchScreenButton: 
			var value = input_map[inp]
			inp.pressed.connect(func(): 
				click_in_button = true
				touched = false
				draged = false
				simulateKeyPressed(value) 
			)
			inp.released.connect(func(): 
				click_in_button = false
				simulateKeyReleased(value) )
	
	scene_updated()
	get_tree().scene_changed.connect(scene_updated)
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
func scene_updated():
	var in_state = get_tree().current_scene.name in ['PlayState']
	%Esc.visible = !in_state
	use_notes = in_state

func _input(ev: InputEvent) -> void:
	if !Global.is_on_mobile:
		return;
		
	if !use_notes and !click_in_button:
		if ev is InputEventScreenTouch:
			if ev.pressed:
				touches[ev.index] = ev.position;
				
				if touches.size() == 1:
					touchDelay = Time.get_unix_time_from_system()
					draged = true
					touched = true
					
			else:
				touches.erase(ev.index);
				
				if touches.size() == 0 && touched: 
					simulateKeyPressed(["enter"])
					
			var two_fingers = touches.size() >= 2;
			
			if two_fingers != reset_touch_active:
				reset_touch_active = two_fingers;
				
				if reset_touch_active:
					Input.action_press("r_reset");
				else:
					Input.action_release("r_reset");
					
		if ev is InputEventScreenDrag:
			var drag_pos = ev.screen_relative
			
			if ( abs(drag_pos.y) > MIN_DRAG_SPD || abs(drag_pos.x) > MIN_DRAG_SPD ) && draged:
				touched = false
				draged = false
				if drag_pos.y < 0: simulateKeyPressed(["ui_up"]) 
				if drag_pos.y > 0: simulateKeyPressed(["ui_down"])  
				
				if drag_pos.x < 0: simulateKeyPressed(["ui_left"]) 
				if drag_pos.x > 0: simulateKeyPressed(["ui_right"]) 

func update_note_visibility(visi:bool):
	use_notes = visi
	%Enter.visible = visi
	notesKeys.visible = visi
	
func simulateKeyReleased(actionList:PackedStringArray = [""]):
	for key in actionList:
		
		var fakeKey = InputEventKey.new()
		fakeKey.keycode = GlobalOptions.keys[key][0]
		fakeKey.pressed = false
		Input.parse_input_event(fakeKey)

func simulateKeyPressed(actionList:PackedStringArray = [""]):
	for key in actionList:
		
		var fakeKey = InputEventKey.new()
		fakeKey.keycode = GlobalOptions.keys[key][0]
		fakeKey.pressed = true
		Input.parse_input_event(fakeKey)
	
	#for action in actionList:
		#
		#var fakeInput = InputEventAction.new()
		#fakeInput.action = action
		#fakeInput.pressed = true
		#Input.parse_input_event(fakeInput)

#func simulateInput(keycodeList:Array[Key] = [], actionKey:PackedStringArray = [""]):
	#var all_lists:Array[Key] = keycodeList
	#
	#if len(actionKey) > 0:
		#for action in actionKey:
			#if action.is_empty() || !InputMap.has_action(action): continue
			#for input in InputMap.action_get_events(action):
				#if input is InputEventKey: all_lists.append(input.keycode)
		#
	#var filtered_list:Array[Key] = []
	#for input in all_lists:
		#if !filtered_list.has(input):
			#print("pRESS", OS.keyc)
			#filtered_list.append(input)
	#
	#for input in filtered_list:
		#var inputkeycode = InputEventKey.new()
		#inputkeycode.keycode = input
		#Input.parse_input_event(inputkeycode)
