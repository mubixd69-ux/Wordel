extends Control

const ROWS = 6
const COLS = 5
const GREEN = Color.GREEN
const YELLOW = Color.YELLOW
const GRAY = Color.DIM_GRAY

var titles = []

var current_row = 0
var current_col = 0

var words = [
	"PIZZA", "BAGEL", "MANGO", "PASTA", "SUSHI", "TOAST",
	"BREAD", "LEMON", "GRAPE", "CANDY", "PEACH", "SALAD",
	"HORSE", "TIGER", "SHARK", "ZEBRA", "OTTER", "KOALA",
	"EAGLE", "SNAKE", "MOUSE", "WHALE", "PANDA", "LLAMA",
]

var answer = "	"

func _ready() -> void:
	answer = words.pick_random()
	print("answer: " + answer)
	
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var bg = ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
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
			box.color = Color.WEB_GRAY
			grid.add_child(box)
			var label = Label.new()
			label.set_anchors_preset(Control.PRESET_FULL_RECT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 32)
			box.add_child(label)
			row_titles.append(box)
		titles.append(row_titles)
	
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
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
		return
	
	check_guess()
	
	if current_row >= ROWS - 1:
		return
	
	current_row += 1
	current_col = 0
	
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
	
	
	
	
	
	
	
