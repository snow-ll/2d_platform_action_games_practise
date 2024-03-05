extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var sprite_2d = $Node2D/Sprite2D
# 控制郊狼时间
@onready var coyote_timer: Timer = $CoyoteTimer
# 控制落地立即跳跃
@onready var jump_timer: Timer = $JumpTimer

const SPEED = 200.0
const JUMP_VELOCITY = -500.0

var x_velocity = 0
var y_velocity = 0
var x_direction = 0
var is_landing = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") as float

func _physics_process(delta) -> void:
	move(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		jump_timer.start()
	if event.is_action_released("move_jump") and velocity.y < JUMP_VELOCITY/ 2:
		velocity.y = JUMP_VELOCITY / 2

func move(delta):
	# 重力
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# 跳跃控制
	var jump_conditions = jump_timer.time_left > 0 and (is_on_floor() or coyote_timer.time_left > 0);
	if jump_conditions:
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		jump_timer.stop()
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	annimation_play(direction)
	
	# 记录移动前是否站在地板上
	var was_on_floor = is_on_floor()
	# 移动
	move_and_slide()
	
	# 移动后地板状态改变并且之前站在地板上
	if is_on_floor() != was_on_floor:
		# 排除主动跳跃
		if was_on_floor and not jump_conditions:
			coyote_timer.start()
		else:
			coyote_timer.stop()

func annimation_play(direction):
	# AnimationPlayer切换动画
#	if velocity.x == 0:
#		animation_player.play("idle")
#	else:
#		animation_player.play("walking")

	# AnimationTree-AnimationNodeStateMachine
	# Condition切换动画
#	if velocity.x == 0:
#		animation_tree["parameters/conditions/is_idle"] = true
#		animation_tree["parameters/conditions/is_walking"] = false
#	else:
#		animation_tree["parameters/conditions/is_walking"] = true
#		animation_tree["parameters/conditions/is_idle"] = false
	
	# Expression切换动画
	x_velocity = velocity.x
	y_velocity = velocity.y
	x_direction = direction
