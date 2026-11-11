extends Control

const ROWS = 6
const COLS = 5

var titles = []

func _ready() -> void:
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
			box.color = Color.DIM_GRAY
			grid.add_child(box)
			row_titles.append(box)
		titles.append(row_titles)
	
	
	
	
	
	
	
	
	
	
