extends Control

const ROWS = 6
const COLS = 5
const GREEN = Color("6a994e")
const YELLOW = Color("d4a72c")
const GRAY = Color("4a5450")
const EMPTY = Color("232c29")
const BG = Color("1c2321")
const TEXT = Color("ece8d8")
const ACCENT = Color("d4a72c")
const BORDER = Color("3a4743")
const BORDER_TYPED = Color("d8d2bc")
const FONT = preload("res://assets/SpaceMono-Bold.ttf")

var titles = []

var current_row = 0
var current_col = 0

var words = [
	"PIZZA", "BAGEL", "MANGO", "PASTA", "SUSHI", "TOAST",
	"BREAD", "LEMON", "GRAPE", "CANDY", "PEACH", "SALAD",
	"HORSE", "TIGER", "SHARK", "ZEBRA", "OTTER", "KOALA",
	"EAGLE", "SNAKE", "MOUSE", "WHALE", "PANDA", "LLAMA",
]

var answer = ""
var valid_words = []
var game_over = false
var message_label
var busy = false

func _ready() -> void:
	load_valid_words()
	answer = words.pick_random()
	print("answer: " + answer)
	
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var bg = ColorRect.new()
	bg.color = BG	
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	center.add_child(column)
	
	var title = Label.new()
	title.text = "Wordel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_font_override("font", FONT)
	title.add_theme_color_override("font_color", TEXT)
	column.add_child(title)
	
	var grid = GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	column.add_child(grid)
	
		
	
	for row in ROWS:
		var row_titles = []
		for col in COLS:
			var box = Panel.new()
			box.custom_minimum_size = Vector2(64, 64)
			set_tile_style(box, EMPTY, BORDER)
			grid.add_child(box)
			var label = Label.new()
			label.set_anchors_preset(Control.PRESET_FULL_RECT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 32)
			label.add_theme_font_override("font", FONT)
			label.add_theme_color_override("font_color", TEXT)
			box.add_child(label)
			row_titles.append(box)
		titles.append(row_titles)
		
	message_label = Label.new()
	message_label.add_theme_font_size_override("font_size", 20)
	message_label.add_theme_font_override("font", FONT)
	message_label.add_theme_color_override("font_color", ACCENT)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(344, 70)
	column.add_child(message_label)
	
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
	
	if busy:
		return
	
	if game_over:
		if event.keycode == KEY_ENTER:
			get_tree().reload_current_scene()
		return
	
	if event.keycode == KEY_BACKSPACE:
		delete_letter()
	elif event.keycode == KEY_ENTER:
		submit_guess()
	elif event.keycode >= KEY_A and event.keycode <= KEY_Z:
		add_letter(char(event.keycode))
	
	
func add_letter(letter):
	if current_col >= COLS:
		return
	
	var box = titles[current_row][current_col]
	var label = box.get_child(0)
	label.text = letter
	set_tile_style(box, EMPTY, BORDER_TYPED)
	pop_tile(box)
	
	current_col += 1
	
func submit_guess():
	if current_col < COLS:
		message_label.text = "Nout enough letters"
		shake_row()
		return
	
	var guess = ""
	for i in COLS:
		guess += titles[current_row][i].get_child(0).text
	
	if not (valid_words.has(guess) or words.has(guess)):
		message_label.text = "that is not a real word booo"
		shake_row()
		return
	
	check_guess()
	await check_guess()
	
	if guess == answer:
		message_label.text = "You got it!"
		bounce_row()
		game_over = true
		return
	
	if current_row >= ROWS - 1:
		message_label.text = "The word was " + answer
		game_over = true
		return
	
	current_row += 1
	current_col = 0
	message_label.text = ""	
	
func delete_letter():
	if current_col == 0:
		return
	
	current_col -= 1
	
	var box = titles[current_row][current_col]
	var label = box.get_child(0)
	label.text = ""
	set_tile_style(box, EMPTY, BORDER)
	

func check_guess():
	var colors = []
	for i in COLS:
		colors.append(GRAY)
		
	var leftover = []
	
	for i in COLS:
		var letter = titles[current_row][i].get_child(0).text
		if letter == answer[i]:
			colors[i] = GREEN
		else:
			leftover.append(answer[i])
	
	for i in COLS:
		if colors[i] == GREEN:
			continue
		var letter = titles[current_row][i].get_child(0).text
		if leftover.has(letter):
			colors[i] = YELLOW
			leftover.erase(letter)
	
	busy = true
	for i in COLS:
		flip_tile(titles[current_row][i], colors[i], i * 0.25)
	
	await get_tree().create_timer(1.4).timeout
	busy = false

func load_valid_words():
	var file = FileAccess.open("res://assets/wordle-La.txt", FileAccess.READ)
	if file == null:
		print("i cnat find file ")
		return
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges().to_upper()
		if line.length() == COLS:
			valid_words.append(line)
	print("loaded words: ", valid_words.size() )
	
func set_tile_style(box, fill, border):
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(2)
	box.add_theme_stylebox_override("panel", style)
	
func flip_tile(box, color, delay):
	box.pivot_offset = box.size / 2
	
	var tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(box, "scale:y", 0.0, 0.2)
	tween.tween_callback(set_tile_style.bind(box, color, color))
	tween.tween_property(box, "scale:y", 1.0, 0.2)

func pop_tile(box):
	box.pivot_offset = box.size / 2
	
	var tween = create_tween()
	tween.tween_property(box, "scale", Vector2(1.1, 1.1), 0.06)
	tween.tween_property(box, "scale", Vector2(1.0, 1.0), 0.06)
	

func shake_row():
	busy = true
	
	for i in COLS:
		var box = titles[current_row][i]
		var x = box.position.x
		
		var tween = create_tween()
		tween.tween_property(box, "position:x", x + 8, 0.05)
		tween.tween_property(box, "position:x", x - 8, 0.05)
		tween.tween_property(box, "position:x", x + 5, 0.05)
		tween.tween_property(box, "position:x", x - 5, 0.05)
		tween.tween_property(box, "position:x", x, 0.05)
	
	await get_tree().create_timer(0.3).timeout
	busy = false

func bounce_row():
	for i in COLS:
		var box = titles[current_row][i]
		var y = box.position.y
		
		var tween = create_tween()
		tween.tween_interval(i * 0.1)
		tween.tween_property(box, "position:y", y - 20, 0.15)
		tween.tween_property(box, "position:y", y, 0.15)
