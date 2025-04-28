extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var health_bar = $HealthBar
@export var speed = 150
@export var jump_force = 260
@export var gravity = 10
@export var max_health = 100
@export var damage_taken = 20
@export var death_threshold = 230

var attacking = false
var health = max_health
var dead = false
var hurt = false


func _process(delta):
	if global_position.y > death_threshold and not dead:
		print("Played fell to their death")
		die()

	health_bar.value = health
	if attacking or hurt or dead:
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	else:
		if Input.is_action_pressed("crouch"):
			if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				sprite.play("crouch_walk")
			else:
				sprite.play("crouch")
		elif Input.is_action_pressed("move_left"):
			sprite.play("run")
			sprite.flip_h = true
		elif Input.is_action_pressed("move_right"):
			sprite.play("run")
			sprite.flip_h = false
		else:
			sprite.play("idle")

func _physics_process(delta):
	if dead:
		return
	
	velocity.y += gravity

	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed
	
	move_and_slide()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	if Input.is_action_just_pressed("attack") and not attacking:
		attack()

func attack():
	if dead:
		return

	attacking = true
	sprite.play("attack")
	#print("Player attacked the enemy!")

	var overlapping_bodies = attack_area.get_overlapping_bodies()
	#print("Enemies in range:", overlapping_bodies)
	
	for body in overlapping_bodies:
		print("Detected body: ", body) 
		if body.is_in_group("enemy"):  
			print("Enemy hit: ", body)  
			body.take_damage(damage_taken)

	_await_attack_delay()

func _await_attack_delay():
	await get_tree().create_timer(0.5).timeout 
	attacking = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Enemy":
		body.take_damage(damage_taken)

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "Enemy":
		pass
		#print("Enemy left attack range!")

func hit():
	if dead:
		return
	
	hurt = true
	sprite.play("hurt")
	await sprite.animation_finished
	hurt = false

func update_animation():
	if attacking or hurt or dead:
		return  
		
	if velocity.x != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func take_damage(amount):
	if dead:
		return
	
	health -= amount
	print("Player took damage! Health: ", health)
	
	if health > 0:
		hit() 
		 
	if health <= 0 and not dead:
		die()

func die():
	if dead:
		return 
	
	dead = true
	sprite.play("die")  
	print("Player has died!")
	await sprite.animation_finished
	
	var restart_screen = get_tree().current_scene.get_node("ScreenOverlay(Restart)")
	restart_screen.show_restart()

	queue_free()
	
	
func check_victory():
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("Enemies found:", enemies.size())

	if enemies.is_empty():
		print("No enemies found!")
		var victory_screen = get_tree().current_scene.get_node("ScreenOverlay(Victory)")
		victory_screen.show_victory()
		return
	
	for enemy in enemies:
		print("Checking enemy:", enemy.name, "Dead?:", enemy.dead)
		if not enemy.dead:
			return

	print("All enemies defeated!")
	var victory_screen = get_tree().current_scene.get_node("ScreenOverlay(Victory)")
	victory_screen.show_victory()
	
