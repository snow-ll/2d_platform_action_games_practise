extends CharacterBody2D

@export var can_combo: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var graphics: Node2D = $Graphics

# 控制郊狼时间
@onready var coyote_timer: Timer = $CoyoteTimer
# 控制落地立即跳跃
@onready var jump_timer: Timer = $JumpTimer
@onready var head_checker: RayCast2D = $Graphics/HeadChecker
@onready var foot_checker: RayCast2D = $Graphics/FootChecker
@onready var states: Node = $States

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -500.0

var x_velocity: float = 0
var y_velocity: float = 0
var x_direction: float = 0
var is_landing: bool = false

# 攻击检测
var is_attack: bool = false
var is_attack1: bool = false
var is_attack2: bool = false
var is_attack3: bool = false
var is_skill_1: bool = false

# 受伤检测
var is_death: bool = false
var is_hurt: bool = false

var x = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float

func _ready() -> void:
	animation_tree.connect("animation_finished", Callable(self, "_on_animation_tree_animation_finished"))

func _physics_process(delta) -> void:
	move(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		jump_timer.start()
	if event.is_action_released("move_jump") and velocity.y < JUMP_VELOCITY/ 2:
		velocity.y = JUMP_VELOCITY / 2
	attack(event)

	
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"attack_1":
			is_attack1 = false
			is_attack = false
		"attack_2":
			is_attack2 = false
			is_attack = false
		"attack_3":
			is_attack3 = false
			is_attack = false
		"skill_1":
			is_skill_1 = false
			is_attack = false
		"hurt":
			is_hurt = false
		"die":
			queue_free()

func _on_hurt_box_hurt(hitbox) -> void:
	states.hp -= 1
	if states.hp <= 0:
		is_hurt = true
		is_death = true
	else:
		is_hurt = true	

func move(delta) -> void:
	if is_death:
		return
	if not is_on_floor():
		fall(delta)
		
	if is_on_wall():
		x = x + 1 
		
	# 跳跃控制
	var jump_conditions = jump_timer.time_left > 0 and (is_on_floor() or coyote_timer.time_left > 0);
	if jump_conditions:
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		jump_timer.stop()
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		graphics.scale.x = -1 if direction < 0 else 1
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
		if was_on_floor && !jump_conditions:
			coyote_timer.start()
		else:
			coyote_timer.stop()

func attack(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack"):
		is_attack = true
		if !is_attack1:
			is_attack1 = true
		if is_attack1 && can_combo:
			is_attack2 = true
		if is_attack2 && can_combo:
			is_attack3 = true
	if Input.is_action_just_pressed("skill_1"):
		is_attack = true
		is_skill_1 = true

func fall(delta) -> void:
	var default_gravity = gravity / 2
	# 重力
	if is_on_wall():
		velocity.y += gravity * delta
	else:
		velocity.y += gravity * delta

func annimation_play(direction) -> void:
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
