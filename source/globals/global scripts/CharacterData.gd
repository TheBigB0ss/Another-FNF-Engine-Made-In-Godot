class_name CharacterData extends Node2D

var charData = {};

var charPath = '';
var animList = [];
var posesList = [];
var icon = '';

var healthColor = Color();

func _ready():
	if charPath == '':
		charPath = 'bf';
