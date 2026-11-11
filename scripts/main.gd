extends Control

const ROWS = 6
const COLS = 5
const GREEN = Color("2a9d8f")
const YELLOW = Color("e0a030")
const GRAY = Color("3b3750")
const EMPTY = Color("1e1b20")
const BG = Color("14121f")
const TEXT = Color("f4f1ff")
const ACCENT = Color("b8a9ff")

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
	
	var title = Label.new()
	title.text = "Wordel"
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 70
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font size", 48)
	title.add_theme_color_override("font_color", TEXT)
	add_child(title)
	
	var grid = GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	center.add_child(grid)
	
	for row in ROWS:
		var row_titles = []
		for col in COLS:
			var box = ColorRect.new()
			box.custom_minimum_size = Vector2(64, 64)
			box.color = EMPTY
			grid.add_child(box)
			var label = Label.new()
			label.set_anchors_preset(Control.PRESET_FULL_RECT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 32)
			label.add_theme_color_override("font_color", TEXT)
			box.add_child(label)
			row_titles.append(box)
		titles.append(row_titles)
		
		message_label = Label.new()
		message_label.add_theme_font_size_override("font_size", 28)
		message_label.add_theme_color_override("font_color", ACCENT)
		message_label.position = Vector2(20, 20)
		add_child(message_label)
	
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
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
	
	current_col += 1
	
func submit_guess():
	if current_col < COLS:
		message_label.text = "Nout enough letters"
		return
	
	var guess = ""
	for i in COLS:
		guess += titles[current_row][i].get_child(0).text
	
	if not (valid_words.has(guess) or words.has(guess)):
		print("that is not a real word booo")
		return
	
	check_guess()
	
	if guess == answer:
		message_label.text = "You got it!"
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
	
	for i in COLS:
		titles[current_row][i].color = colors[i]
	
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
	
	
	
	
