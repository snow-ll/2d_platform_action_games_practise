extends Enemy

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var idle_timer: Timer = $IdleTimer
@onready var animation_tree: AnimationTree = $AnimationTree

var is_walk: bool = false
var is_death: bool = false
var is_hurt: bool = false

func _ready() -> void:
	idle_timer.start()
	animation_tree.connect("animation_finished", Callable(self, "_on_animation_tree_animation_finished"))

func _physics_process(delta: float) -> void:
	skeleton_move(delta)

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"die":
			queue_free()
		"hurt":
			is_hurt = false

func _on_hurt_box_hurt(hitbox) -> void:
	states.hp -= 1
	if states.hp <= 0:
		is_death = true
	else:
		is_hurt = true

func skeleton_move(delta: float):
	if is_death:
		return
	if not idle_timer.time_left == 0:
		idle_timer.stop()
		is_walk = true
	if wall_checker.is_colliding() || (is_on_floor() && !floor_checker.is_colliding()):
		is_walk = false
		idle_timer.start()
		direction *= -1
		
	if not player_checker.is_colliding():
		super.move(SPEED, delta)
	else:
		super.move(SPEED * 1.5, delta)
		
	move_and_slide()

