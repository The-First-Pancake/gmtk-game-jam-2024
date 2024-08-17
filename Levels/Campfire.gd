class_name Campfire
extends Area2D

@onready var fire_particle_fx: CPUParticles2D = %"Fire Particle FX" as CPUParticles2D
var is_lit: bool:
	set(val):
		is_lit = val
		fire_particle_fx.emitting = val
	get:
		return fire_particle_fx.emitting
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_lit = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
