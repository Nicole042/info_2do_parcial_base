extends Node2D

# state machine
enum {WAIT, MOVE}
var state

# grid
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var y_offset: int

# piece array
var possible_pieces = [
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
]

# current pieces in scene
var all_pieces = []

# swap back
var piece_one = null
var piece_two = null
var last_place = Vector2.ZERO
var last_direction = Vector2.ZERO
var move_checked = false
var should_consume_move = false

# touch variables
var first_touch = Vector2.ZERO
var final_touch = Vector2.ZERO
var is_controlling = false

# === Temporizadores del ciclo destruir → colapsar → rellenar ===
# Son nodos hijos de "grid"; el editor conecta sus señales "timeout" a este script.
@onready var destroy_timer: Timer = $destroy_timer
@onready var collapse_timer: Timer = $collapse_timer
@onready var refill_timer: Timer = $refill_timer

var swap_sound = AudioStreamPlayer.new()
var match_sound = AudioStreamPlayer.new()
var invalid_sound = AudioStreamPlayer.new()

# === PUNTAJE (B1) y CONTADOR (B2) ===
# Contrato sugerido para comunicarte con el HUD (top_ui.gd). No es obligatorio usar
# señales, pero ayuda a mantener la UI desacoplada de la lógica del tablero:
#   signal score_changed(nuevo_puntaje: int)
#   signal counter_changed(restantes: int)        # movimientos o segundos, tú decides
#   signal game_finished(gano: bool)
# TODO (PARCIAL · B1/B2): declara aquí el puntaje y el contador (y sus señales, si las usas).
signal score_changed(nuevo_puntaje: int)
signal counter_changed(restantes: int)
signal game_finished(gano: bool)

var score = 0
var moves_left = 20
var points_per_piece = 10
var target_score = 300
var game_is_finished = false

var current_level_index = 0
var current_level: LevelConfig

var levels = [
	preload("res://levels/level_1.tres"),
	preload("res://levels/level_2.tres"),
	preload("res://levels/level_3.tres")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	state = MOVE
	randomize()
	all_pieces = make_2d_array()
	load_level(current_level_index)
	spawn_pieces()
	
	add_child(swap_sound)
	add_child(match_sound)
	add_child(invalid_sound)

	swap_sound.stream = load("res://assets/Match 3 Sounds/Sounds/1.ogg")
	match_sound.stream = load("res://assets/Match 3 Sounds/Sounds/4.ogg")
	invalid_sound.stream = load("res://assets/Match 3 Sounds/Sounds/7.ogg")
	
	var top_ui = get_parent().get_node("top_ui")
	score_changed.connect(top_ui.update_score)
	counter_changed.connect(top_ui.update_counter)
	score_changed.emit(score)
	counter_changed.emit(moves_left)

func load_level(index: int):
	current_level = levels[index]

	target_score = current_level.objetivo_valor
	moves_left = current_level.limite_movimientos

	score = 0
	
	print("Nivel cargado: ", current_level.nombre)
	print("Meta: ", target_score)
	print("Movimientos: ", moves_left)

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
	
func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)
	
func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)
	
func in_grid(column, row):
	return column >= 0 and column < width and row >= 0 and row < height
	
func spawn_pieces():
	for i in width:
		for j in height:
			# random number
			var rand = randi_range(0, possible_pieces.size() - 1)
			# instance 
			var piece = possible_pieces[rand].instantiate()
			# repeat until no matches
			var max_loops = 100
			var loops = 0
			while (match_at(i, j, piece.color) and loops < max_loops):
				rand = randi_range(0, possible_pieces.size() - 1)
				loops += 1
				piece = possible_pieces[rand].instantiate()
			add_child(piece)
			piece.position = grid_to_pixel(i, j)
			# fill array with pieces
			all_pieces[i][j] = piece

func match_at(i, j, color):
	# check left
	if i > 1:
		if all_pieces[i - 1][j] != null and all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color and all_pieces[i - 2][j].color == color:
				return true
	# check down
	if j > 1:
		if all_pieces[i][j - 1] != null and all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color and all_pieces[i][j - 2].color == color:
				return true
	return false

func touch_input():
	var mouse_pos = get_global_mouse_position()
	var grid_pos = pixel_to_grid(mouse_pos.x, mouse_pos.y)
	if Input.is_action_just_pressed("ui_touch") and in_grid(grid_pos.x, grid_pos.y):
		first_touch = grid_pos
		is_controlling = true
		
	# release button
	if Input.is_action_just_released("ui_touch") and in_grid(grid_pos.x, grid_pos.y) and is_controlling:
		is_controlling = false
		final_touch = grid_pos
		touch_difference(first_touch, final_touch)

func swap_pieces(column, row, direction: Vector2):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece == null or other_piece == null:
		return
	# swap
	state = WAIT
	store_info(first_piece, other_piece, Vector2(column, row), direction)
	all_pieces[column][row] = other_piece
	all_pieces[column + direction.x][row + direction.y] = first_piece
	#first_piece.position = grid_to_pixel(column + direction.x, row + direction.y)
	#other_piece.position = grid_to_pixel(column, row)
	first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
	other_piece.move(grid_to_pixel(column, row))
	swap_sound.play()
	# TODO (PARCIAL · M3): si alguna de las piezas intercambiadas es especial,
	# actívala aquí (su efecto reemplaza a la búsqueda normal de combinaciones).
	# TODO (PARCIAL · B2): un intercambio válido consume una jugada. Decide dónde
	# descontar el contador: aquí, o en destroy_matched() solo si hubo combinación.
	if not move_checked:
		should_consume_move = true
		if not m3_activate_swap(column, row, direction):
			m3_find_matches()

func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction

func swap_back():
	if piece_one != null and piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = MOVE
	move_checked = false

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	# should move x or y?
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	if abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))

func _process(_delta):
	if game_is_finished:
		if Input.is_key_pressed(KEY_R):
			if score >= target_score:
				go_to_next_level()
			else:
				get_tree().reload_current_scene()
		return
		
	if state == MOVE:
		touch_input()

func find_matches():
	# TODO (PARCIAL · M3): aquí es donde se decide qué piezas forman cada combinación.
	# Para crear piezas especiales necesitas conocer el LARGO de cada línea: una de 4
	# genera una pieza de línea (fila/columna) y una de 5 una bomba de color. El chequeo
	# actual solo mira el "centro" de tríos; probablemente tengas que recorrer las
	# líneas completas para distinguir combinaciones de 3, 4 y 5.
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				# detect horizontal matches
				if (
					i > 0 and i < width - 1 
					and 
					all_pieces[i - 1][j] != null and all_pieces[i + 1][j]
					and 
					all_pieces[i - 1][j].color == current_color and all_pieces[i + 1][j].color == current_color
				):
					all_pieces[i - 1][j].matched = true
					all_pieces[i - 1][j].dim()
					all_pieces[i][j].matched = true
					all_pieces[i][j].dim()
					all_pieces[i + 1][j].matched = true
					all_pieces[i + 1][j].dim()
				# detect vertical matches
				if (
					j > 0 and j < height - 1 
					and 
					all_pieces[i][j - 1] != null and all_pieces[i][j + 1]
					and 
					all_pieces[i][j - 1].color == current_color and all_pieces[i][j + 1].color == current_color
				):
					all_pieces[i][j - 1].matched = true
					all_pieces[i][j - 1].dim()
					all_pieces[i][j].matched = true
					all_pieces[i][j].dim()
					all_pieces[i][j + 1].matched = true
					all_pieces[i][j + 1].dim()
					
	destroy_timer.start()
	
func destroy_matched():
	var was_matched = false
	
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and all_pieces[i][j].matched:
				was_matched = true
				score += points_per_piece
				score_changed.emit(score)
				all_pieces[i][j].queue_free()
				all_pieces[i][j] = null

	move_checked = true
	
	if should_consume_move:
		moves_left -= 1
		counter_changed.emit(moves_left)
		should_consume_move = false
	
	if was_matched:
		match_sound.play()
		m3_spawn_pending()
		collapse_timer.start()
	else:
		invalid_sound.play()
		
		if moves_left <= 0:
			game_over(false)
			return
		
		swap_back()

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				# look above
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	refill_timer.start()

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				# random number
				var rand = randi_range(0, possible_pieces.size() - 1)
				# instance 
				var piece = possible_pieces[rand].instantiate()
				# repeat until no matches
				var max_loops = 100
				var loops = 0
				while (match_at(i, j, piece.color) and loops < max_loops):
					rand = randi_range(0, possible_pieces.size() - 1)
					loops += 1
					piece = possible_pieces[rand].instantiate()
				add_child(piece)
				piece.position = grid_to_pixel(i, j - y_offset)
				piece.move(grid_to_pixel(i, j))
				# fill array with pieces
				all_pieces[i][j] = piece
				
	check_after_refill()

func check_after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and match_at(i, j, all_pieces[i][j].color):
				find_matches()
				destroy_timer.start()
				return

	# El tablero quedó estable: no hay más combinaciones en cascada.
	# TODO (PARCIAL · M1): verifica si se cumplió o falló el objetivo del nivel
	# (puntaje meta, piezas recolectadas, etc.) y dispara victoria o derrota.
	# TODO (PARCIAL · M2): comprueba si todavía existe alguna jugada válida; si no,
	# rebaraja el tablero hasta que haya al menos una.
	if score >= target_score:
		game_over(true)
		return

	if moves_left <= 0:
		game_over(false)
		return

	if not hay_jugadas_validas():
		rebarajar()

	state = MOVE
	move_checked = false

func go_to_next_level():
	current_level_index += 1
	
	if current_level_index >= levels.size():
		current_level_index = 0
	
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				all_pieces[i][j].queue_free()
				all_pieces[i][j] = null
	
	score = 0
	game_is_finished = false
	move_checked = false
	should_consume_move = false
	
	load_level(current_level_index)
	score_changed.emit(score)
	counter_changed.emit(moves_left)
	
	spawn_pieces()
	state = MOVE

func _on_destroy_timer_timeout():
	destroy_matched()

func _on_collapse_timer_timeout():
	collapse_columns()

func _on_refill_timer_timeout():
	refill_columns()
	
func game_over(gano: bool):
	state = WAIT
	# TODO (PARCIAL · B3): muestra la pantalla final (victoria o derrota), detén la
	# entrada del jugador y ofrece reiniciar la partida. Emite game_finished(gano).
	# TODO (PARCIAL · M4): guarda el progreso (nivel alcanzado) y el mejor puntaje
	# en disco (user://) para conservarlos entre sesiones.
	game_is_finished = true
	game_finished.emit(gano)
	
	var final_label = Label.new()
	add_child(final_label)
	final_label.add_theme_color_override("font_outline_color", Color.BLACK)
	final_label.add_theme_constant_override("outline_size", 4)
	
	if gano:
		final_label.text = current_level.nombre + " COMPLETE!\nScore: " + str(score) + "\nPress R for next level"
	else:
		final_label.text = "GAME OVER\nScore: " + str(score) + "\nPress R to retry"
	
	final_label.modulate = Color.LIME_GREEN
	final_label.position = Vector2(170, 280)
	final_label.add_theme_font_size_override("font_size", 39)

# TODO (PARCIAL · M2): funciones sugeridas para detectar el bloqueo del tablero.
# func hay_jugadas_validas() -> bool:
# func rebarajar() -> void:
func hay_match_en_tablero() -> bool:
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var color = all_pieces[i][j].color
				
				if i < width - 2:
					if all_pieces[i + 1][j] != null and all_pieces[i + 2][j] != null:
						if all_pieces[i + 1][j].color == color and all_pieces[i + 2][j].color == color:
							return true
				
				if j < height - 2:
					if all_pieces[i][j + 1] != null and all_pieces[i][j + 2] != null:
						if all_pieces[i][j + 1].color == color and all_pieces[i][j + 2].color == color:
							return true
	
	return false
func hay_jugadas_validas() -> bool:
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				
				if i < width - 1 and all_pieces[i + 1][j] != null:
					var temp = all_pieces[i][j]
					all_pieces[i][j] = all_pieces[i + 1][j]
					all_pieces[i + 1][j] = temp
					
					var hay_match = hay_match_en_tablero()
					
					temp = all_pieces[i][j]
					all_pieces[i][j] = all_pieces[i + 1][j]
					all_pieces[i + 1][j] = temp
					
					if hay_match:
						return true
				
				if j < height - 1 and all_pieces[i][j + 1] != null:
					var temp = all_pieces[i][j]
					all_pieces[i][j] = all_pieces[i][j + 1]
					all_pieces[i][j + 1] = temp
					
					var hay_match = hay_match_en_tablero()
					
					temp = all_pieces[i][j]
					all_pieces[i][j] = all_pieces[i][j + 1]
					all_pieces[i][j + 1] = temp
					
					if hay_match:
						return true
	
	return false
func rebarajar():
	print("No hay jugadas validas. Rebarajando tablero...")
	
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				all_pieces[i][j].queue_free()
				all_pieces[i][j] = null
	
	spawn_pieces()
	
	if not hay_jugadas_validas():
		rebarajar()


# M3 — PIEZAS ESPECIALES

var _pending_specials = []

func m3_find_matches() -> void:
	for j in height:
		var i = 0
		while i < width:
			if all_pieces[i][j] == null:
				i += 1
				continue
			var col = all_pieces[i][j].color
			var len = 1
			while i + len < width and all_pieces[i + len][j] != null and all_pieces[i + len][j].color == col:
				len += 1
			if len >= 3:
				for k in len:
					all_pieces[i + k][j].matched = true
					all_pieces[i + k][j].dim()
				if len == 4:
					_pending_specials.append({"col": i + 1, "row": j, "type": "row", "color": col})
				elif len >= 5:
					_pending_specials.append({"col": i + 2, "row": j, "type": "rainbow", "color": col})
			i += len

	for i in width:
		var j = 0
		while j < height:
			if all_pieces[i][j] == null:
				j += 1
				continue
			var col = all_pieces[i][j].color
			var len = 1
			while j + len < height and all_pieces[i][j + len] != null and all_pieces[i][j + len].color == col:
				len += 1
			if len >= 3:
				for k in len:
					all_pieces[i][j + k].matched = true
					all_pieces[i][j + k].dim()
				if len == 4:
					_pending_specials.append({"col": i, "row": j + 1, "type": "column", "color": col})
				elif len >= 5:
					_pending_specials.append({"col": i, "row": j + 2, "type": "rainbow", "color": col})
			j += len

	destroy_timer.start()

func m3_spawn_pending() -> void:
	for s in _pending_specials:
		if all_pieces[s.col][s.row] == null:
			var piece = preload("res://scenes/piece.tscn").instantiate()
			piece.color = s.color
			piece.special_type = s.type
			var color_cap = s.color.capitalize()
			add_child(piece)
			piece.position = grid_to_pixel(s.col, s.row)
			all_pieces[s.col][s.row] = piece
			var spr = piece.get_node("Sprite2D")
			if s.type == "row":
				spr.texture = load("res://assets/pieces/" + color_cap + " Row.png")
			elif s.type == "column":
				spr.texture = load("res://assets/pieces/" + color_cap + " Column.png")
			elif s.type == "rainbow":
				spr.texture = load("res://assets/pieces/Rainbow.png")
	_pending_specials.clear()

func m3_activate_swap(column: int, row: int, direction: Vector2) -> bool:
	var p1 = all_pieces[column][row]
	var p2 = all_pieces[column + int(direction.x)][row + int(direction.y)]
	if p1 == null or p2 == null:
		return false
	if p1.special_type == "" and p2.special_type == "":
		return false
	var c2 = column + int(direction.x)
	var r2 = row + int(direction.y)
	if p1.special_type != "" and p2.special_type != "":
		m3_combo(p1, p2, column, row, c2, r2)
	elif p1.special_type == "rainbow":
		clear_color(p2.color)
		p1.matched = true
	elif p2.special_type == "rainbow":
		clear_color(p1.color)
		p2.matched = true
	elif p1.special_type != "":
		p1.activate_special(self)
		p1.matched = true
	else:
		p2.activate_special(self)
		p2.matched = true
	destroy_timer.start()
	return true

func m3_combo(p1, p2, c1, r1, c2, r2) -> void:
	if p1.special_type == "rainbow":
		clear_color(p2.color)
	elif p2.special_type == "rainbow":
		clear_color(p1.color)
	elif (p1.special_type == "row" and p2.special_type == "column") or (p1.special_type == "column" and p2.special_type == "row"):
		clear_row(r1)
		clear_column(c1)
	elif p1.special_type == "row" and p2.special_type == "row":
		clear_row(r1)
		clear_row(r2)
	elif p1.special_type == "column" and p2.special_type == "column":
		clear_column(c1)
		clear_column(c2)
	all_pieces[c1][r1].matched = true
	all_pieces[c2][r2].matched = true

func clear_row(row: int) -> void:
	for i in width:
		if all_pieces[i][row] != null:
			all_pieces[i][row].matched = true
			all_pieces[i][row].dim()

func clear_column(col: int) -> void:
	for j in height:
		if all_pieces[col][j] != null:
			all_pieces[col][j].matched = true
			all_pieces[col][j].dim()

func clear_color(target_color: String) -> void:
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and all_pieces[i][j].color == target_color:
				all_pieces[i][j].matched = true
				all_pieces[i][j].dim()
