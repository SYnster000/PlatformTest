extends CharacterBody2D


const SPEED = 200.0
const JUMP_FORCE = -400.0

var is_jumping := false
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
	move_and_slide()
	

#region CONTROLE DE ANIMAÇÕES

	
	animation.speed_scale = 1
	
	
	if direction > 0:
		animation.scale.x = 1
	elif direction < 0:
		animation.scale.x = -1
		
	
	if is_jumping:
		animation.play("jump")
	elif direction:
		animation.play("run")
		animation.speed_scale = abs(direction)
	else:
		animation.play("idle")
#endregion
	


func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("teste")
	if body.is_in_group("enemies"):
		queue_free()


func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
