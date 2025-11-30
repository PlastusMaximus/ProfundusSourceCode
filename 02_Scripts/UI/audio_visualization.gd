class_name AudioVisualization extends Control

## Number of frequency bands to display
const NUM_BARS: float = 23
## Frequency range to analyze
const MAX_FREQ: float = 1000  

@export var shuffle_freq: bool = false
@export var flip_y: bool = true

var spectrum_instance

var bars: Array = []


var color_gradient: Gradient = Gradient.new()  # Dynamic color transitions


func _ready():
	global_position = Vector2(40, 1041)
	# Set up color gradient (Blue → Purple → Red)
	scale = Vector2(1, .45)
	color_gradient.add_point(0.0, Color(0.2, 1.0, 0.8))  # Cyan
	color_gradient.add_point(0.3, Color(1.0, 1.0, 0.0, 1.0))  # Purple
	color_gradient.add_point(0.6, Color(1.0, 0.0, 0.0, 1.0))  # Red
	spectrum_instance = AudioServer.get_bus_effect_instance(2, 0)  # Bus 1, Effect 0
	create_bars()

func create_bars():
	for i in range(NUM_BARS):
		var bar = ColorRect.new()
		bar.color = Color(0.2, 0.8, 1.0)  # Light blue color
		bar.size = Vector2(8, 50)  # Adjust bar size
		bar.position = Vector2(i*10, 0)  # Space bars apart
		add_child(bar)
		bars.append(bar)

func _process(_delta):
	if not spectrum_instance:
		return
	var max_freq_amp = bars.reduce(func(m, b): return b if b.size.y > m.size.y else m).size.y 
	
	for i in range(NUM_BARS):
		var freq_start = (i * MAX_FREQ) / NUM_BARS
		var freq_end = ((i + 1) * MAX_FREQ) / NUM_BARS
		var magnitude = spectrum_instance.get_magnitude_for_frequency_range(freq_start, freq_end).length()
		bars[i].size.y = lerp(bars[i].size.y, magnitude * 1000 * 2, 0.2)  # Smooth animation
		
		var intensity = (magnitude*1000) / (max_freq_amp * 1000.0) if max_freq_amp > 0 else 0.0
		intensity *= 1000
		intensity = clamp(intensity, 0.0, 1.0)  # Keep within valid range

		# Get dynamic color from gradient
		var new_color = color_gradient.sample(intensity)
		bars[i].color = new_color
		if flip_y:
			bars[i].scale.y = -1
	
	if shuffle_freq:
			bars.shuffle()
