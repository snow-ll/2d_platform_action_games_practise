class_name Enemy
extends CharacterBody2D

enum Direction {
	LEFT = 1,
	RIGHT = -1
}

@export var direction: float = Direction.LEFT:
	set(V):
		direction = V
		if not is_node_ready():
			await ready
		graphics.scale.x = direction

@onready var graphics: Node2D = $Graphics
@onready var states: Node = $States

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func move(speed: float, delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = direction * speed
