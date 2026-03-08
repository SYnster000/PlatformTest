extends CharacterBody2D


const SPEED = 200.0
const JUMP_FORCE = -400.0

var is_jumping := false
@export var player_life := 10
var is_hurted := false
var knockback_vector := Vector2.ZERO

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_jumping = true
	else:
		is_jumping = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	move_and_slide()
	

#region CONTROLE DE ANIMAÇÕES

	
	animation.speed_scale = 1
	
	
	if direction > 0:
		animation.scale.x = 1
	elif direction < 0:
		animation.scale.x = -1
		
	
		
	if is_hurted:
		animation.play("hurt")
	elif is_jumping:
		animation.play("jump")
	elif direction:
		animation.play("run")
		animation.speed_scale = abs(direction)
	else:
		animation.play("idle")
#endregion
	


func _on_hurtbox_body_entered(body: Node2D) -> void:
	#if body.is_in_group("enemies"):
		#queue_free()
	if player_life < 0:
		queue_free()
	else:
		if $ray_right.is_colliding():
			take_damage(Vector2(-200,-200))
		if $ray_left.is_colliding():
			take_damage(Vector2(200,-200))

func take_damage(knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1
	
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween()
		knockback_tween.parallel().tween_property(self,"knockback_vector",Vector2.ZERO,duration)
		animation.modulate = Color(1.0, 0.0, 0.0, 1.0)
		knockback_tween.parallel().tween_property(animation, "modulate", Color(1,1,1,1), duration)
		
	is_hurted = true
	await  get_tree().create_timer(.3).timeout
	is_hurted = false
		


func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
