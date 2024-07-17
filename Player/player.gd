extends CharacterBody2D

var bullet = preload("res://Player/bullet.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var muzzle : Marker2D = $Muzzle

@onready var health_bar = $HealthBar
@onready var health_manager = $HealthManager

const GRAVITY = 1000

@export var max_health = 100
@export var current_health = max_health

@export var Speed : int = 1500
@export var Max_Horizontal_Speed: int = 300
@export var Slow_Down_Speed : int = 1300

@export var Jump : int = -350
@export var Jump_Horizontal_Speed : int = 1000
@export var Max_Jump_Horizontal_Speed: int = 270

enum State { idle, run, jump, shoot }

var current_state : State
var muzzle_position

var character_sprite : Sprite2D

func _ready():
	current_state = State.idle
	muzzle_position = muzzle.position
	health_bar.set_max_health(health_manager.max_health)
	health_manager.on_health_change.connect(health_bar.update_health)

func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	player_muzzle_position()
	player_shooting(delta)
	
	move_and_slide()
	
	player_animation()
	
	#print("State: ", State.keys()[current_state])


func player_falling(delta : float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta


func player_idle(delta : float):
	if is_on_floor():
		current_state = State.idle


func player_run(delta : float):
	if !is_on_floor():
		return
	
	var direction = input_movement()
	
	if direction:
		velocity.x += direction * Speed * delta
		velocity.x = clamp(velocity.x, -Max_Horizontal_Speed, Max_Horizontal_Speed)
	else:
		velocity.x = move_toward(velocity.x, 0, Slow_Down_Speed * delta)
	
	if direction != 0:
		current_state = State.run
		animated_sprite_2d.flip_h = direction < 0


func player_jump(delta : float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = Jump
		current_state = State.jump
	
	if !is_on_floor() and current_state == State.jump:
		var direction = input_movement()
		velocity.x += direction * Jump_Horizontal_Speed * delta
		velocity.x = clamp(velocity.x, -Max_Jump_Horizontal_Speed, Max_Jump_Horizontal_Speed)

func player_shooting(delta : float):
	var direction = input_movement()
	
	if direction != 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = direction
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
		current_state = State.shoot 

func player_muzzle_position():
	var direction = input_movement()
	
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x

func take_damage(amount):
	print("Taking damage: ", amount)
	current_health = max(0, current_health - amount)
	health_bar.set_health(current_health)
	print("Current health: ", current_health)
	
	if current_health <= 0:
		die() # xử lý player chết

func die():
	pass

func heal(amount):
	current_health = min(max_health, current_health + amount)
	health_bar.set_health(current_health)

func player_animation():
	if current_state == State.idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.run and is_on_floor() and animated_sprite_2d.animation != "run_shoot":
		animated_sprite_2d.play("run")
	elif current_state == State.jump:
		animated_sprite_2d.play("jump")
	elif current_state == State.shoot:
		animated_sprite_2d.play("run_shoot")

func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	
	return direction


func _on_hurtbox_body_entered(body : Node2D):
	if body.is_in_group("Enemy"):
		#print("Enemy entered ", body.damage_amount)
		HealthManager.decrease_health(body.damage_amount)
