extends Node


@export var recursive = true
@export var keep_originals = true
@export_enum("Convert .scn to .tscn",
			 "Convert .tscn to .scn",
			 "Check for errors in scenes and scripts") var operation_type: int

@export_group("Files")
@export_dir var directory = "res://"

enum OPERATION_TYPES {BIN_TO_TEXT, TEXT_TO_BIN, CHECK_ERRORS}


func _ready():
	if   operation_type == OPERATION_TYPES.BIN_TO_TEXT:
		bin_to_text()
	elif operation_type == OPERATION_TYPES.TEXT_TO_BIN:
		text_to_bin()
	elif operation_type == OPERATION_TYPES.CHECK_ERRORS:
		check_errors()
	else:
		printerr("Parse Error: Bad operation type '%s'" % operation_type)

func _process(_delta): get_tree().quit()


func bin_to_text():
	var directories = [directory]
	for dir_path in directories:
		if dir_path == "":
			continue
		var dir = DirAccess.open(dir_path)
		var err = DirAccess.get_open_error()
		if err != OK:
			printerr("ERROR!!! %s" % err)
		else:
			dir.list_dir_begin()
			var filename = dir.get_next()
			while (filename != ""):
				if (!dir.current_is_dir() and filename.split(".")[-1] == "scn"):
					var scene = load([dir.get_current_dir() + "/" + filename])
					ResourceSaver.save(scene, dir.get_current_dir() + "/" + filename.left(filename.length() - 4) + ".tscn")
					print("saved '%s.tscn'" % (dir.get_current_dir() + "/" + filename.left(filename.length() - 4)))
					if (!keep_originals):
						dir.remove(dir.get_current_dir() + "/" + filename)
						print("Deleted '%s'" % (dir.get_current_dir() + "/" + filename))
				elif (dir.current_is_dir() and recursive and !(filename == "." || filename == "..")):
					directories.append(dir.get_current_dir() + "/" + filename)
				filename = dir.get_next()
		dir.list_dir_end()

func text_to_bin():
	var directories = [directory]
	for dir_path in directories:
		if dir_path == "":
			continue
		var dir = DirAccess.open(dir_path)
		var err = DirAccess.get_open_error()
		if err != OK:
			printerr("ERROR!!! %s" % err)
		else:
			dir.list_dir_begin()
			var filename = dir.get_next()
			while (filename != ""):
				if (!dir.current_is_dir() and filename.split(".")[-1] == "tscn"):
					var scene = load(dir.get_current_dir() + "/" + filename)
					ResourceSaver.save(scene, "%s.scn" % (dir.get_current_dir() + "/" + filename.left(filename.length() - 5)))
					print("Saved '%s.scn'" % (dir.get_current_dir() + "/" + filename.left(filename.length() - 5)))
					if (!keep_originals):
						dir.remove(dir.get_current_dir() + "/" + filename)
						print("Deleted '%s'" % (dir.get_current_dir() + "/" + filename))
				elif (dir.current_is_dir() and recursive and !(filename == "." || filename == "..")):
					directories.append(dir.get_current_dir() + "/" + filename)
				filename = dir.get_next()
		dir.list_dir_end()

func check_errors():
	var directories = [directory]
	var filename
	var tmp_
	for dir_path in directories:
		var dir = DirAccess.open(dir_path)
		var err = DirAccess.get_open_error()
		if err != OK:
			printerr("ERROR!!!" + err)
		else:
			dir.list_dir_begin()
			filename = dir.get_next()
			while filename != "":
				if dir.current_is_dir() and filename not in [".godot", ".git", "addons", "android", "..", "."]:
					directories.append(dir.get_current_dir() + "/" + filename)
				elif filename.split(".", true, 1)[-1] in ["gd", "scn", "tscn", "res", "tres"]:
					print("Attempt to open: '%s'" % (dir.get_current_dir() + ("" if dir.get_current_dir() == "res://" else "/") + filename))
					tmp_ = load(dir.get_current_dir() + ("" if dir.get_current_dir() == "res://" else "/") + filename)
				filename = dir.get_next()
		dir.list_dir_end()
