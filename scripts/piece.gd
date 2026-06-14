extends Node2D

@export var color: String

var matched = false

# TODO (PARCIAL · M3): para las piezas especiales podrías guardar aquí su tipo
# (por ejemplo, "fila", "columna" o "bomba") y exponer un método que dispare su
# efecto sobre el tablero cuando se active.

func move(target):
	var move_tween = create_tween()
	move_tween.set_trans(Tween.TRANS_ELASTIC)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", target, 0.4)

func dim():
	$Sprite2D.modulate = Color(1, 1, 1, 0.5)

#m3 
var special_type: String = ""

func activate_special(grid) -> void:
	if special_type == "row":
		grid.clear_row(int(round((position.y - grid.y_start) / -grid.offset)))
	elif special_type == "column":
		grid.clear_column(int(round((position.x - grid.x_start) / grid.offset)))
	elif special_type == "rainbow":
		pass
