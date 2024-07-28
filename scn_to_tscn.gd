@tool

class_name SceneChecker
extends EditorScript


enum OPERATION_TYPES {BIN_TO_TEXT, TEXT_TO_BIN, CHECK_ERRORS, RESAVE_ALL}

@export var recursive: bool = true
@export var keep_originals: bool = true
@export_enum("Convert .scn to .tscn",
			 "Convert .tscn to .scn",
			 "Check for errors in scenes and scripts")
var operation_type: int = 2

@export_dir var directory: String = "res://"


func _run() -> void:
	print("RUN")

	operation_type = OPERATION_TYPES.RESAVE_ALL

	match operation_type:
		OPERATION_TYPES.BIN_TO_TEXT:
			bin_to_text()
		OPERATION_TYPES.TEXT_TO_BIN:
			text_to_bin()
		OPERATION_TYPES.CHECK_ERRORS:
			check_errors()
		OPERATION_TYPES.RESAVE_ALL:
			resave_all_files()
		_:
			printerr("Parse Error: Bad operation type '%s'" % operation_type)


func bin_to_text():
	var directories: Array[String] = [directory]
	for dir_path in directories:
		if dir_path == "":
			continue
		var dir: DirAccess = DirAccess.open(dir_path)
		var err: int = DirAccess.get_open_error()
		if err != OK:
			printerr("ERROR!!! %s" % err)
		else:
			dir.list_dir_begin()
			var filename: String = dir.get_next()
			while (filename != ""):
				if (!dir.current_is_dir() and filename.split(".", true, 1)[-1] == "scn"):
					var scene: Resource = load(dir.get_current_dir() + "/" + filename)
					ResourceSaver.save(scene, dir.get_current_dir() + "/" + filename.left(filename.length() - 4) + ".tscn")
					print("saved '%s.tscn'" % (dir.get_current_dir() + "/" + filename.left(filename.length() - 4)))
					if (!keep_originals):
						dir.remove(dir.get_current_dir() + "/" + filename)
						print("Deleted '%s'" % (dir.get_current_dir() + "/" + filename))
				elif (dir.current_is_dir() and recursive and not (filename == "." or filename == "..")):
					directories.append(dir.get_current_dir() + "/" + filename)
				filename = dir.get_next()
		dir.list_dir_end()


func text_to_bin():
	var directories: Array[String] = [directory]
	for dir_path in directories:
		if dir_path == "":
			continue
		var dir: DirAccess = DirAccess.open(dir_path)
		var err: int = DirAccess.get_open_error()
		if err != OK:
			printerr("ERROR!!! %s" % err)
		else:
			dir.list_dir_begin()
			var filename: String = dir.get_next()
			while (filename != ""):
				if (!dir.current_is_dir() and filename.split(".", true, 1)[-1] == "tscn"):
					var scene: Resource = load(dir.get_current_dir() + "/" + filename)
					ResourceSaver.save(scene, "%s.scn" % (dir.get_current_dir() + "/" + filename.left(filename.length() - 5)))
					print("Saved '%s.scn'" % (dir.get_current_dir() + "/" + filename.left(filename.length() - 5)))
					if (!keep_originals):
						dir.remove(dir.get_current_dir() + "/" + filename)
						print("Deleted '%s'" % (dir.get_current_dir() + "/" + filename))
				elif (dir.current_is_dir() and recursive and not (filename == "." or filename == "..")):
					directories.append(dir.get_current_dir() + "/" + filename)
				filename = dir.get_next()
		dir.list_dir_end()


func check_errors():
	var directories: Array[String] = [directory]
	var filename: String
	for dir_path in directories:
		var dir: DirAccess = DirAccess.open(dir_path)
		var err: int = DirAccess.get_open_error()
		if err != OK:
			printerr("ERROR!!! %s" % err)
		else:
			dir.list_dir_begin()
			filename = dir.get_next()
			while filename != "":
				if dir.current_is_dir() and filename not in [".godot", ".git", "addons", "android", "..", "."]:
					directories.append(dir.get_current_dir() + "/" + filename)
				elif filename.split(".", true, 1)[-1] in ["gd", "scn", "tscn", "res", "tres", "gdshader"]:
					print("Checking: '%s'" % (dir.get_current_dir() + ("" if dir.get_current_dir() == "res://" else "/") + filename))
					load(dir.get_current_dir() + ("" if dir.get_current_dir() == "res://" else "/") + filename)
				filename = dir.get_next()
		dir.list_dir_end()


func resave_all_files():
	var directories: Array[String] = ["res://"]
	
	for dirr in directories:
		var dir: DirAccess = DirAccess.open(dirr)
		var err: int = DirAccess.get_open_error()

		if err != OK:
			printerr("ERROR!!! %s" % err)
		else:
			dir.list_dir_begin()
			var filename: String = dir.get_next()
			while filename != "":
				if !dir.current_is_dir() and filename.split(".", true, 1)[-1] in ["gd", "scn", "tscn", "res", "tres", "gdshader"]:
					var scene: Resource = load(dir.get_current_dir() + "/" + filename)
					ResourceSaver.save(scene, "%s" % (dir.get_current_dir() + "/" + filename))
					print("Saved '%s'" % (dir.get_current_dir() + "/" + filename))
				elif dir.current_is_dir() and recursive and not (filename == "." or filename == ".."):
					directories.append(dir.get_current_dir() + "/" + filename)
				filename = dir.get_next()
			dir.list_dir_end()


# nuh uh
"""
	var popup: Popup = Popup.new()
	popup.size = Vector2(200, 200)
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_FULL_RECT

	var switch_recursive: CheckButton = CheckButton.new()
	switch_recursive.text = "recursive"
	switch_recursive.button_pressed = true

	var switch_keep_originals: CheckButton = CheckButton.new()
	switch_keep_originals.text = "keep_originals"
	switch_keep_originals.button_pressed = true

	var itlist: ItemList = ItemList.new()
	itlist.add_item("Convert .scn to .tscn")
	itlist.add_item("Convert .tscn to .scn")
	itlist.add_item("Check for errors in scenes and scripts")

	var fil: FileDialog = FileDialog.new()
	fil.file_mode = FileDialog.FILE_MODE_OPEN_DIR

	vbox.add_child(switch_recursive)
	vbox.add_child(switch_keep_originals)
	vbox.add_child(itlist)
	vbox.add_child(fil)

	popup.add_child(vbox)

	get_editor_interface().get_editor_main_screen().add_child(popup)

	popup.show()

	await popup.popup_hide

	operation_type = itlist.get_selected_items()[0]
	recursive = switch_recursive.button_pressed
	keep_originals = switch_keep_originals.button_pressed
"""
