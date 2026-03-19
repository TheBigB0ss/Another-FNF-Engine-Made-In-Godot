extends Stage

func _ready() -> void:
	$friend.visible = (friend_chance() <= 50);
	
func _process(delta: float) -> void:
	if $friend.visible:
		await get_tree().create_timer(1.1).timeout;
		$friend.modulate.a = lerp($friend.modulate.a, 0.0, 0.55);
		
func friend_chance():
	return int(randi_range(0, 50));
