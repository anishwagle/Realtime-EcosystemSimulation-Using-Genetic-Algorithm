extends GridContainer

export var line_width = 1
export(Color) var line_color
export(Color) var bg_color

export var x_label = ""
export var y_label = ""

export var x_ticks = 10
export var y_ticks = 5

var x_numerical = true
var y_numerical = true

var min_x
var min_y
var max_x
var max_y

var line_rect_width
var line_rect_height

var line_rect_x
var line_rect_y
#
#var data = [
#	{'x': 'MON', 'y': 7.0},
#	{'x': 'TUE', 'y': 8.0},
#	{'x': 'WED', 'y': 3.0},
#	{'x': 'THU', 'y': 5.0},
#	{'x': 'FRI', 'y': 4.0},
#	{'x': 'SAT', 'y': 6.0},
#	{'x': 'SUN', 'y': 1.0},
#]

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func resetGraph():
	min_x=null
	min_y=null
	max_x=null
	max_y=null
	delete_children($line_container/Control)
	delete_children($x_ticks_container)
	delete_children($y_ticks_container)
func UpdateGraph(data,graph_txt):
	
	resetGraph()
	# generate line and apply style
	var line = Line2D.new()
	line.width = line_width
	line.default_color = line_color
	$line_container/Control.add_child(line)
	
	$x_label.text = graph_txt
#	$y_label.text = y_label
	$line_container/background.color = bg_color
	
	# check if values are numerical
	for val in data:
		if not [TYPE_INT, TYPE_REAL].has(typeof(val['x'])):
			x_numerical = false
		if not [TYPE_INT, TYPE_REAL].has(typeof(val['y'])):
			y_numerical = false
		
	# get min and max values (use index if value isn't a number, e.g. weekdays)
	for i in range(data.size()):
		var x_val = get_val(data[i]['x'], i)
		var y_val = get_val(data[i]['y'], i)
		
		if min_x == null or x_val < min_x:
			min_x = x_val
		if max_x == null or x_val > max_x:
			max_x = x_val
		if min_y == null or y_val < min_y:
			min_y = y_val
		if max_y == null or y_val > max_y:
			max_y = y_val
	
	# add tick labels to each axis
	for i in range(x_ticks):
		
		var x_tick = Label.new()
		x_tick.size_flags_horizontal = SIZE_EXPAND_FILL
		x_tick.align = HALIGN_CENTER
		if x_numerical:
			x_tick.text = str(round(i * (max_x-min_x) / (x_ticks-1) + min_x)) # optional rounding
		else:
			x_tick.text = str(data[i]['x'])
		$x_ticks_container.add_child(x_tick)
	
	for i in range(y_ticks):
		var y_tick = Label.new()
		y_tick.size_flags_vertical = SIZE_EXPAND_FILL
		y_tick.valign = VALIGN_CENTER
		if y_numerical:
			y_tick.text = str(round(i * (max_y-min_y) / (y_ticks-1) + min_y)) # optional rounding
		else:
			y_tick.text = str(data[i]['y'])
		$y_ticks_container.add_child(y_tick)
	
		# fix updated rect sizes not having correct values after altering labels
#	yield(get_tree(), "idle_frame") or yield(VisualServer, "frame_post_draw")
	
	# shape the line
	line_rect_width = $line_container.rect_size.x
	line_rect_height = $line_container.rect_size.y
	
	line_rect_x = (line_rect_width / x_ticks)
	line_rect_y = (line_rect_height / y_ticks)
	
	line_rect_width = line_rect_x * (x_ticks-1)
	line_rect_height = line_rect_y * (y_ticks-1)
	
	for i in range(len(data)):
		var scaled_x = scale_x(get_val(data[i]['x'], i))
		var scaled_y = scale_y(get_val(data[i]['y'], i))
		line.add_point(Vector2(scaled_x, scaled_y))
	

func scale_x(val):
	var dx = max_x - min_x
	if dx == 0:
		dx=0.01
	return ((val - min_x) * line_rect_width / dx) + line_rect_x/2


func scale_y(val):
	var dy = max_y - min_y
	if dy==0:
		dy=0.001
	return line_rect_height - ((val - min_y) * line_rect_height / dy) + line_rect_y/2


func get_val(val, idx):
	if [TYPE_INT, TYPE_REAL].has(typeof(val)):
		return val
	return idx
