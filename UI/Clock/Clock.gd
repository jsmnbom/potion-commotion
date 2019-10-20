extends Node2D

var size = 48
var pixel_size = 3
var center = Vector2(200,200)

var theta = PI*0.3

#let draw_line = (x0, y0, x1, y1) => {
#
#    // Calculate "deltas" of the line (difference between two ending points)
#    let dx = x1 - x0;
#    let dy = y1 - y0;
#
#    // Calculate the line equation based on deltas
#    let D = (2 * dy) - dx;
#
#    let y = y0;
#
#    // Draw the line based on arguments provided
#    for (let x = x0; x < x1; x++)
#    {
#        // Place pixel on the raster display
#        pixel(x, y);
#
#        if (D >= 0)
#        {
#             y = y + 1;
#             D = D - 2 * dx;
#        }
#
#        D = D + 2 * dy;
#    }
#};

func draw_pixel_line(from, to, pixel_size):
	var orig_from = from
	to = (to - from) / pixel_size
	from = Vector2(0,0)
	print(from, to)
	
	var dx = to.x - from.x
	var dy = to.y - from.y
	
	var D = (2 * dy) - dx
	
	var y = from.y
	
	for x in range(from.x, to.x):
		prints(x, y)
		draw_rect(Rect2(orig_from+(Vector2(x,y)*pixel_size), Vector2(pixel_size, pixel_size)), Color.black)
		#draw_primitive(PoolVector2Array([)]), PoolColorArray([Color(1,1,1)]),PoolVector2Array())
		
		if D >= 0:
			y = y + 1
			D = D - 2 * dx
		D = D + 2 * dy

func _ready():
	$TextureRect.texture = Utils.get_scaled_res('res://assets/ui/clock.png', 48, 48)

func _process(delta):
	theta = (theta + PI*0.01)
	if theta >= TAU:
		theta = 0
	update()

func _draw():
	if theta < PI/2:
		draw_pixel_line(Vector2(20,20), polar2cartesian(7*3, theta)+Vector2(20,20), 4)