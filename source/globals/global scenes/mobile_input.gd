extends Node2D

@onready var controlls = $Controlls
@onready var otherKeys = controlls.get_node("Others")
@onready var notesKeys = controlls.get_node("Notes")

var input_map:Dictionary[Node, PackedStringArray] = {
	%Esc: ["escape"],
	%Enter: ["enter"],
	
	%Left: ["left"],
	%Down: ["down"],
	%Up: ["up"],
	%Right: ["right"]
}

var draged = false
var touchDelay = 0.

var touched = false
var use_notes = false:set=update_note_visibility

const MIN_DRAG_SPD = 2.

func _ready() -> void:
	
	use_notes = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	for inp in input_map:
		if inp is not TouchScreenButton: continue
		var value = input_map[inp]
		inp.pressed.connect(func():
			print('aperto', value)
			simulateKey(value)
		)

func _input(ev: InputEvent) -> void:
	#if ev.is_action_pressed():
		#print("Input fake funcionando")
	
	if ev is InputEventScreenTouch:
		if ev.pressed: 
			touchDelay = Time.get_unix_time_from_system()
			draged = true
			touched = true
		else:
			if touched: 
				simulateKey(["enter"])
				

		
		
	if ev is InputEventScreenDrag:
		var drag_pos = ev.screen_relative
		
		if ( abs(drag_pos.y) > MIN_DRAG_SPD || abs(drag_pos.x) > MIN_DRAG_SPD ) && draged:
			touched = false
			draged = false
			if drag_pos.y < 0: simulateKey(["ui_up"]) 
			if drag_pos.y > 0: simulateKey(["ui_down"])  
			
			if drag_pos.x < 0: simulateKey(["ui_left"]) 
			if drag_pos.x > 0: simulateKey(["ui_right"]) 

func update_note_visibility(visi:bool):
	use_notes = visi
	notesKeys.visible = visi

func simulateKey(actionList:PackedStringArray = [""]):
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
