class_name Campfire
extends Area2D

@onready var smoke_particle_fx: GPUParticles2D =  %"Smoke Particle FX" as GPUParticles2D
@onready var ember_particle_fx: GPUParticles2D =  %"Ember Particle FX" as GPUParticles2D
@onready var flame_sprite: AnimatedSprite2D = %"Flame Sprite" as AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var flag_sprite: AnimatedSprite2D = $"Flag Sprite"


var is_lit: bool:
	set(val):
		is_lit = val
		smoke_particle_fx.emitting = val
		ember_particle_fx.emitting = val
		point_light_2d.visible = val
		flame_sprite.visible = val
		if val == true:
			flame_sprite.play("ignite")
			await flame_sprite.animation_looped
			flame_sprite.play("burning")
	get:
		return smoke_particle_fx.emitting
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_lit = false
	flag_sprite.play("wave")
	var parent: Node = get_parent()
	if parent is Placeable:
		parent.placed.connect(func() -> void:
			if abs(global_rotation_degrees) > 20:
				fall()
		)

func fall() -> void:
	var gibs: Node2D = %Gibs as Node2D
	if gibs == null: return
	await get_tree().process_frame
	gibs.process_mode = Node.PROCESS_MODE_INHERIT
	gibs.reparent(get_tree().current_scene)
	
	await get_tree().process_frame
	gibs.visible = true
	queue_free()

func extinguish() -> void:
	is_lit = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("water"):
		extinguish()

func _on_body_entered(body: Node2D) -> void:
	var parent: Node = get_parent()
	if parent is Placeable:
		if parent.state != parent.PlaceState.PLACED:
			return
	if body is Placeable:
		if body != get_parent():
			fall()
