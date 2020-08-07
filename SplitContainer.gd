extends VSplitContainer

var tile_width = 64
var tile_height = 64

var tiles = []
var image_format

func _ready():
	$MarginContainer/HBoxContainer/LineEditWidth.set_text(str(self.tile_width))
	$MarginContainer/HBoxContainer/LineEditHeight.set_text(str(self.tile_height))


func _on_ButtonOpenFile_pressed():
	$FileDialogOpenFile.popup_centered()


func _on_ButtonSaveFile_pressed():
	$FileDialogSaveFile.popup_centered()


func _on_ButtonCredits_pressed():
	$AcceptDialogCredits.popup_centered()


func _on_LineEditWidth_text_changed(new_text):
	self.tile_width = int(new_text)
	print(self.tile_width)


func _on_LineEditHeight_text_changed(new_text):
	self.tile_height = int(new_text)


func _on_FileDialogOpenFile_file_selected(path):
	loadSheet(path)
	rebuildGrid()


func _on_FileDialogSaveFile_file_selected(path):
	saveSheet(path)

# Swap source and target tiles when dropped
func _on_Tile_dropped(source, target):
	var tiles_copy = self.tiles.duplicate(true)
	var source_row = source[0]
	var source_col = source[1]
	var target_row = target[0]
	var target_col = target[1]
	
	tiles_copy[source_row][source_col] = self.tiles[target_row][target_col]
	tiles_copy[source_row][source_col].row = source_row
	tiles_copy[source_row][source_col].col = source_col
	
	tiles_copy[target_row][target_col] = self.tiles[source_row][source_col]
	tiles_copy[target_row][target_col].row = target_row
	tiles_copy[target_row][target_col].col = target_col
	
	self.tiles = tiles_copy.duplicate(true)
	rebuildGrid()

func newTextureRect(sheet, col, row):
	var rect = Rect2(col * self.tile_width, row * self.tile_height, self.tile_width, self.tile_height)
	var image = sheet.get_rect(rect)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	var textureRect = TextureRect.new()
	textureRect.texture = texture
	return textureRect

func loadSheet(path):
	var sheet = Image.new()
	sheet.load(path)
	self.image_format = sheet.get_format()
	var rows = sheet.get_height() / self.tile_height
	var cols = sheet.get_width() / self.tile_width
	$GridContainer.columns = cols
	self.tiles.resize(rows)
	for row in range(rows):
		self.tiles[row] = []
		self.tiles[row].resize(cols)
		for col in range(cols):
			var tile = newTextureRect(sheet, col, row)
			tile.set_position(Vector2(row * self.tile_height, col * self.tile_width))
			var script = load("res://Tile.gd")
			tile.set_script(script)
			tile.col = col
			tile.row = row
			tile.connect("dropped", self, "_on_Tile_dropped")
			self.tiles[row][col] = tile

func saveSheet(path):
	var rows = self.tiles.size()
	var cols = self.tiles[0].size()
	var sheet = Image.new()
	sheet.create(cols * self.tile_width, rows * self.tile_height, false, self.image_format)
	
	for row in range(rows):
		for col in range(cols):
			var current_tile = self.tiles[row][col]
			var texture = current_tile.texture
			var image = texture.get_data()
			var src_rect =  Rect2(0, 0, self.tile_width, self.tile_height)
			var dst = Vector2(col * self.tile_width, row * self.tile_height)
			sheet.blit_rect(image, src_rect, dst)
	sheet.save_png(path)

func rebuildGrid():
	for child in $GridContainer.get_children():
		$GridContainer.remove_child(child)
	
	var rows = self.tiles.size()
	var cols = self.tiles[0].size()
	for row in range(rows):
		for col in range(cols):
			$GridContainer.add_child(self.tiles[row][col])
