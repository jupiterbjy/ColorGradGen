extends Control


@onready var texture_rect: TextureButton = %TextureRect
@onready var texture: GradientTexture1D = texture_rect.texture_normal
@onready var grad: Gradient = texture.gradient

@onready var color_picker: ColorPicker = %ColorPicker
@onready var color_point_cont: VBoxContainer = %ColorPointCont
@onready var file_dialogue: FileDialog = %FileDialog

@export var color_point_scene: PackedScene = null
@export var color_point_marker: PackedScene = null

var selected_point_idx: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	reload_points()


## Clear points from container
func clear_points() -> void:
	for child in color_point_cont.get_children():
		child.queue_free()
	
	for child in color_point_cont.get_children():
		color_point_cont.remove_child(child)
	
	for child in texture_rect.get_children():
		child.queue_free()


## Add marker on texture. Range is 0.0~1.0.
func add_marker(relative_pos: float) -> void:
	var new_marker: Control = color_point_marker.instantiate()
	texture_rect.add_child(new_marker)
	new_marker.position.x = texture_rect.size.x * relative_pos


## Generate points from gradient. This is inefficient but simpliest
func list_points() -> void:
	for idx: int in range(grad.get_point_count()):
		
		var new_node: ColorPoint = color_point_scene.instantiate()
		color_point_cont.add_child(new_node)
		
		new_node.setup(idx, grad.get_offset(idx), grad.get_color(idx))
		
		# connect click signals
		new_node.clicked_idx.connect(_on_color_point_click)
		new_node.del_requested.connect(_on_color_delete_req)
		new_node.pos_changed.connect(_on_pos_changed)
		
		# add marker
		add_marker(grad.get_offset(idx))


## Select first point
func select_first_point() -> void:
	selected_point_idx = 0
	_on_color_point_click(
		color_point_cont.get_child(0)
	)


## Reload points
func reload_points() -> void:
	clear_points()
	list_points()
	select_first_point()


## Clear highlight state for all points
func unhighlight_all_point() -> void:
	for child: ColorPoint in color_point_cont.get_children():
		child.unhighlight()


## Called on color point selection. Update colorpicker to selected color.
func _on_color_point_click(point: ColorPoint) -> void:
	self.unhighlight_all_point()
	point.highlight()
	
	self.selected_point_idx = point.idx
	self.color_picker.color = point.get_color()


## Called on point deletion request
func _on_color_delete_req(idx: int) -> void:
	self.grad.remove_point(idx)
	reload_points()


## Called on pos change
func _on_pos_changed(idx: int, pos: float) -> void:
	self.grad.set_offset(idx, pos)
	reload_points()


func _on_screen_res_combo_value_changed(value):
	texture.width = value


func _on_interp_mode_option_item_selected(index):
	grad.interpolation_mode = index


func _on_save_dialogue_button_pressed():
	file_dialogue.show()


func _on_file_dialog_file_selected(path: String):
	# https://forum.godotengine.org/t/need-to-generate-and-save-textures-to-disk/32028/2
	
	if path.is_empty():
		return
	
	# make sure to have extention
	if not path.ends_with(".png"):
		path += ".png"
	
	# fetch 1D image
	var img: Image = texture.get_image()
	var width: int = texture.get_width()
	var height: int = width / 8
	
	# create vertically stretched 2D image
	var img_2d: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	# copy pixels to image
	for x_idx in range(width):
		var color: Color = img.get_pixel(x_idx, 0)
		for y_idx in range(height):
			img_2d.set_pixel(x_idx, y_idx, color)
	
	img_2d.save_png(path)
	print("Image sated as " + path)


func _on_mirror_pressed():
	grad.reverse()
	reload_points()


func _on_color_picker_color_changed(color):
	color_point_cont.get_child(selected_point_idx).set_color(color)
	grad.set_color(selected_point_idx, color)


func _on_texture_rect_pressed():
	var mouse_pos: Vector2 = texture_rect.get_local_mouse_position()
	
	# calculate relative pos
	var pos: float = mouse_pos.x / texture_rect.size.x
	print("Creating new point at %s" % pos)
	
	self.grad.add_point(pos, grad.sample(pos))
	reload_points()
