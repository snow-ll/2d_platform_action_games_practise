class_name HitBox
extends Area2D

signal hit(hurt_box: HurtBox)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurt_box: HurtBox) -> void:
#	print("Hit： %s -> %s" % [owner.name, hurt_box.owner.name])
	hit.emit(hurt_box)
	hurt_box.hurt.emit(self)
