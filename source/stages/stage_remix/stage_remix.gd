extends Stage

@onready var crowd = $ParallaxBackground3/ParallaxLayer3;

func _ready() -> void:
	if game.curSong == "tutorial-remix":
		crowd.hide();
		if game.dad.curCharacter == "Girlfriend Remake":
			game.dad.position.x += 110;
