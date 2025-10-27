extends Node2D

@onready var death_pos = $'death_position';

var bf = null;
var death_anim = null;

func _ready():
	bf = load("res://source/characters/" + SongData.player1 + ".tscn").instantiate();
	death_anim = load("res://source/%s.tscn"%[bf.death_scene]).instantiate();
	death_pos.add_child(death_anim);
