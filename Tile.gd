extends TextureRect

signal dropped(source, target)

var row
var col


func get_drag_data(_pos):
	var tile = TextureRect.new()
	tile.texture = texture
	set_drag_preview(tile)
	return [row, col]


func can_drop_data(_pos, data):
	return typeof(data) == TYPE_ARRAY


func drop_data(_pos, data):
	emit_signal("dropped", data, [row, col])
