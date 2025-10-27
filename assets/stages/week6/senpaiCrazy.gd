extends Node2D

@onready var animation = $'Character_Animation';

func _ready():
	animation.seek(0.0)
	
