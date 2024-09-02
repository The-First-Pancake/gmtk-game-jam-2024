extends PointLight2D

var initial_energy: float = 0
var percent_variance: float = .9
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_energy = energy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var noise_gen: FastNoiseLite = FastNoiseLite.new()
	noise_gen.noise_type = FastNoiseLite.TYPE_PERLIN
	energy = initial_energy - initial_energy * percent_variance * noise_gen.get_noise_1d(float(Time.get_ticks_msec())/2)
