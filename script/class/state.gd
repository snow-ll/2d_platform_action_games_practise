class_name States
extends Node

signal hp_changed

@export var max_hp :int = 10

@onready var hp :int = max_hp:
	set(v):
		v = clampi(v, 0,max_hp)
		if hp == v:
			return
		hp = v
		hp_changed.emit()
