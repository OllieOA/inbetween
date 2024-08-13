extends Node

@onready var idle: Node = $Idle
@onready var move: Node = $Move
@onready var jump: Node = $Jump
@onready var fall: Node = $Fall
@onready var dash: Node = $Dash
@onready var slide: Node = $Slide
@onready var hide: Node = $Hide
@onready var kill: Node = $Kill
@onready var caught: Node = $Caught

var all_states: Dictionary = {}

func _ready() -> void:
	for state in get_children():
		all_states[state.get_name] = state
