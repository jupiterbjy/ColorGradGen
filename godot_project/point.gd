extends Control


## Set this on creation
var associated_color_point: ColorPoint = null

var follow_mouse: bool = false


func _on_button_button_down():
	follow_mouse = true


func _on_button_button_up():
	follow_mouse = false
	self.associated_color_point.set_pos(self.position.x / get_parent().size.x)


## Updates point handle position and position value in
## associated color point.
func _update_point_pos() -> void:
	# parent: Texture bar
	var parent = get_parent()
	
	var rect_width: float = parent.size.x
	var mouse_pos: Vector2 = parent.get_local_mouse_position()
	
	self.position.x = clamp(mouse_pos.x, 0.0, rect_width)


func _process(_delta):
	if follow_mouse:
		_update_point_pos()
