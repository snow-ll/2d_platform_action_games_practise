extends HBoxContainer

@export var states: States

@onready var hp: TextureProgressBar = $Hp

func _ready() -> void:
	states.hp_changed.connect(update_hp)
	update_hp()

func update_hp() -> void:
	var pencentHp = states.hp / float(states.max_hp)
	print(states.hp)
	print(states.max_hp)
	hp.value = pencentHp
