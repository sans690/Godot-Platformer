extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var health_bar = $HealthBar
@onready var player = $"../Player"
@export var speed = 50
@export var gravity = 10
@export var patrol_distance = 100
@export var attack_range = 50
@export var attack_delay = 1.0 
@export var max_health = 100 
@export var damage_taken = 10
var attacking = false
var hurt = false


var starting_position
var direction = 1
var player_in_range = false
var player_in_attack_range = false
var can_attack = true 
var health = max_health
var dead = false  

func _ready():
	add_to_group("enemy")

	
	if detection_area.body_entered.is_connected(self._on_detection_area_body_entered):
		detection_area.body_entered.disconnect(self._on_detection_area_body_entered)
	if detection_area.body_exited.is_connected(self._on_detection_area_body_exited):
		detection_area.body_exited.disconnect(self._on_detection_area_body_exited)

	detection_area.body_entered.connect(self._on_detection_area_body_entered)
	detection_area.body_exited.connect(self._on_detection_area_body_exited)

	attack_area.body_entered.connect(self._on_attack_area_body_entered)
	attack_area.body_exited.connect(self._on_attack_area_body_exited)

func _process(delta):
	update_animation()
	health_bar.value = health
	
func follow_player():
	if not player:
		return
	var direction_to_player = (player.global_position.x - global_position.x)
	direction = sign(direction_to_player)
	velocity.x = direction * speed
	sprite.flip_h = direction < 0

func _physics_process(delta):
	if dead:
		return

	velocity.y += gravity

	if player_in_range:
		follow_player()

	move_and_slide()

	if player_in_range and player_in_attack_range and can_attack:
		attack()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		#print("Player entered the detection area! Preparing to attack!")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		#print("Player left the detection area!")

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_attack_range = true
		#print("Player is within attack range!")

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_attack_range = false
		#print("Player is out of attack range!")
		
func attack():
	if dead or attacking:
		return 

	attacking = true
	sprite.play("attack")
	can_attack = false

	if player_in_attack_range:
		var player = get_parent().get_node("Player")
		if player:
			player.take_damage(damage_taken)

	await sprite.animation_finished
	attacking = false
	
	_await_attack_delay()
	
func update_animation():
	if attacking or hurt or dead:
		return
	
	if velocity.x != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func _await_attack_delay():
	await get_tree().create_timer(attack_delay).timeout
	can_attack = true 

func hit():
	if dead:
		return
	
	hurt = true
	sprite.play("hit")
	await sprite.animation_finished
	hurt = false

func take_damage(amount):
	if dead:
		return
	
	health -= amount
	print("Enemy took damage! Health: ", health)
	
	if health > 0:
		hit() 
		 
	if health <= 0 and not dead:
		die()

func die():
	if dead:
		return
	
	dead = true
	sprite.play("die")
	print("Enemy has died!")
	
	await sprite.animation_finished
	queue_free()
