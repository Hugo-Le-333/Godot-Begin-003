extends Node

var max_health : int = 16
var current_health : int

signal on_health_change(new_health : int)

func _ready():
	current_health = max_health
	on_health_change.emit(current_health)


func decrease_health(health_amount : int):
	current_health -= health_amount
	current_health = max(0, current_health)
	
	print("decrease_health called")
	on_health_change.emit(current_health)


func increase_health(health_amount : int):
	current_health += health_amount
	current_health = min(max_health, current_health)
	
	print("increase_health called")
	on_health_change.emit(current_health)
