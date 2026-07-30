extends CharacterScript

var textsGrp = Node2D.new();

var velocity = Vector2.ZERO;
func on_ready():
	add_child(textsGrp);
	
func on_note_hit(_note:Note):
	velocity = Vector2(-randi_range(0, 10),-randi_range(140, 175));
	
	var opponent = get_game_var("dad");
	if get_game_var("curSong") == "tutorial":
		var directionText = Alphabet.new();
		directionText._creat_word(["left!", "down!", "up!", "right!"][_note.noteData]);
		directionText.position = Vector2(opponent.position.x-randi_range(-120, 200), opponent.position.y-randi_range(180, 290));
		directionText.z_index = opponent.z_index+1;
		directionText.modulate.a = 3.5;
		textsGrp.add_child(directionText);
		
func on_process(_delta):
	for i in textsGrp.get_children():
		i.modulate.a = lerp(i.modulate.a, 0.0, 1.0 - exp(-7.0 * _delta));
		i.position -= velocity * _delta;
		
		if i.modulate.a > 0.0:
			continue;
			
		textsGrp.remove_child(i);
		i.queue_free();
		
