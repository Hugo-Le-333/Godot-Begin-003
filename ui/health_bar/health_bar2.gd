extends Control

@onready var health_bar = $TextureProgressBar

func set_health(value):
	print("Setting health to: ", value)
	health_bar.value = value
	health_bar.update()

func get_health():
	return health_bar.value
