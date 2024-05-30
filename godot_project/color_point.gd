class_name ColorPoint extends Button


signal clicked_idx(point: ColorPoint)
signal pos_changed(idx: int, value: float)
signal del_requested(idx: int)


@onready var color_rect: ColorRect = %ColorRect
@onready var selected_bg: ColorRect = %SelectedBackground
@onready var point_spin: SpinBox = %PointPosSpinBox


var idx: int
var pos: float


func setup(idx_: int, pos_: float, color: Color) -> void:
	self.pos = pos_
	self.point_spin.value = pos_
	
	self.set_color(color)
	self.set_idx(idx_)


func set_pos(pos: float) -> void:
	self.pos = pos
	self.point_spin.value = pos


func set_color(color: Color) -> void:
	self.color_rect.color = color


func get_color() -> Color:
	return self.color_rect.color


func set_idx(idx: int) -> void:
	self.idx = idx
	%Label.text = "Point %s" % idx


func highlight() -> void:
	self.selected_bg.show()


func unhighlight() -> void:
	self.selected_bg.hide()


func _on_pressed():
	# Emit another signal just to add idx, kinda feel off but can't help
	clicked_idx.emit(self)


func _on_point_pos_spin_box_value_changed(value):
	pos_changed.emit(idx, value)


func _on_trash_button_pressed():
	self.del_requested.emit(self.idx)
