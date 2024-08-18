class_name Campfire
extends Area2D

@onready var smoke_particle_fx: CPUParticles2D =  %"Smoke Particle FX" as CPUParticles2D
@onready var flame_sprite: AnimatedSprite2D = %"Flame Sprite" as AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var flag_sprite: AnimatedSprite2D = $"Flag Sprite"



var is_lit: bool:
	set(val):
		is_lit = val
		smoke_particle_fx.emitting = val
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
