#----------------------------------------------------------------------------------------
# Awesome Text Editor
# https://github.com/grabaraba/Awesome-Text-Editor
# Under Apache-2.0 License
#----------------------------------------------------------------------------------------


extends PopupPanel
# Source:
# https://docs.godotengine.org/en/stable/classes/class_directory.html?highlight=Directory
# https://www.davidepesce.com/2019/11/04/essential-guide-to-godot-filesystem-api/


# Paths to children nodes.
onready var Title : Node = $Control/Title
onready var PathLineEdit : Node = $Control/ToolBar/PathLineEdit
onready var ButtonNewFolder : Node = $Control/ToolBar/ButtonNewFolder
onready var FileTree : Node = $Control/FileTree
onready var FileLineEdit : Node = $Control/FilePanel/FileLineEdit
onready var ButtonSave : Node = $Control/BottomPanel/ButtonSave
onready var ERROR : Node = $Control/FileTree/ERROR
onready var TimerERROR : Node = $Control/FileTree/TimerERROR
onready var FileExistsPopup : Node = $FileExistsPopup

# Dummy root used as a universal root, since it is not really visible.
onready var dummy_root : Object = FileTree.create_item()
# This is used so the 'FileSystem' is not closed if operation not seccessful.
onready var valid : bool = true
onready var default_open_dir : String = Global.default_open_dir
onready var current_file_path : String = Global.default_open_dir

signal open_RenameDialogBox(title, placeholder)
signal return_loaded_file(loaded_text, project_name, path)


func _on_FileSystem_popup_hide():
	# When the 'FileSystem' is closed, 'ERROR' is made empty so that if it is opened
	# again in less than 5 seconds it does not show previous error message.
	ERROR.text = ""


func _on_PathLineEdit_text_entered(new_text):
	# Called, when the path is entered.
	if not new_text.is_abs_path():
		print("[FileSystem] ERROR:'", new_text, "' is not a valid path!")
		display_error(str(new_text, " is not a valid path!"))
		return
	
	current_file_path = new_text
	print("[FileSystem] Path entered: ", new_text)
	dir_contents(current_file_path, dummy_root)


func _on_FileTree_item_selected():
	var item = get_selected_item()
	var display_path = add_to_path(current_file_path, item.get_text(0))
	PathLineEdit.text = display_path
	
	# If the file is selected, it's name is displayed in 'FileLineEdit'.
	var dir = Directory.new()
	if dir.file_exists(display_path):
		FileLineEdit.text = item.get_text(0)
	else:
		FileLineEdit.text = ""


func _on_FileTree_item_activated():
	# Aparently we have to use Tree methods to get usefull information (thanks discord).
	# get_selected_item() returns the item we clicked.
	var item = get_selected_item()
	var title = item.get_text(0)
	var dir = Directory.new()
	
	if dir.file_exists(current_file_path):
		current_file_path = trim_path(current_file_path)
	elif title == "..":
		current_file_path = trim_path(current_file_path)
	else:
		current_file_path = add_to_path(current_file_path, title)
	
	# Checking if current path valid.
	if  not str(current_file_path).is_abs_path():
		print("[FileSystem] ERROR: can't load directory! Path not valid!")
		display_error("Can't load directory! Path not valid!")
		current_file_path = trim_path(current_file_path)
		return
	
	print("[FileSystem] Item '", title, "' activated")
	if dir.file_exists(current_file_path):
		ButtonSave.emit_signal("pressed")
	else:
		print("[FileSystem] Current path: ", current_file_path)
		PathLineEdit.text = current_file_path
		dir_contents(current_file_path, dummy_root)


func _on_ButtonBack_pressed():
	print("[FileSystem] 'ButtonBack' pressed")
	current_file_path = trim_path(current_file_path)
	dir_contents(current_file_path, dummy_root)
	PathLineEdit.text = current_file_path


func _on_ButtonSave_pressed():
	
	# If the file is being saved:
	if ButtonSave.text == "Save":
		print("[FileSystem] 'Save' button pressed")
		var dir = Directory.new()
		var path = current_file_path
		var tab = Global.script_MainEditorPanel.tabs.current_tab
		
		if not dir.file_exists(current_file_path):
			path = add_to_path(current_file_path, FileLineEdit.text)
		
		save_file(tab, FileLineEdit.text, path)
		if valid == true:
			self.hide()
	
	# If the file is being loaded:
	elif ButtonSave.text == "Load":
		print("[FileSystem] 'Load' button pressed")
		var loaded_text = load_file(PathLineEdit.text)
		var pos = FileLineEdit.text.find_last(".")
		var project_name = FileLineEdit.text
		
		var dir = Directory.new()
		if (dir.file_exists(self.add_to_path(current_file_path, FileLineEdit.text))
		or dir.file_exists(current_file_path)):
			project_name.erase(pos, FileLineEdit.text.length() - pos)
			emit_signal("return_loaded_file", loaded_text, project_name,
			current_file_path)
		else:
			print("[FileSystem] Selected element not file, can not be loaded!")
			display_error("Selected element not file, can not be loaded!")
			valid = false
		
		if valid == true:
			ButtonSave.text = "Save"
			self.hide()
	
	else:
		print("[FileSystem] ERROR: error occurred in '_on_ButtonSave_pressed()!'")
		display_error("Error occurred in '_on_ButtonSave_pressed()!")


func _on_ButtonCancel_pressed():
	ButtonSave.text = "Save"
	self.hide()


func _on_ButtonNewFolder_pressed():
	print("[FileSystem] 'New Folder' button pressed")
	emit_signal("open_RenameDialogBox", "New Folder Name:", Global.default_new_dir_name)


func _on_ButtonNo_pressed():
	FileExistsPopup.hide()


func _on_ButtonYes_pressed():
	var dir = Directory.new()
	var path = current_file_path
	
	# This ensures tha path is a valid path to an existing file.
	if not dir.file_exists(current_file_path):
			path = add_to_path(current_file_path, FileLineEdit.text)
	
	save_file(Global.script_MainEditorPanel.tabs.current_tab,
		FileLineEdit.text, path, true)
	FileExistsPopup.hide()
	if valid == true:
		self.hide()


func _on_MainEditorPanel_open_FileSystem_save(title, file_name):
	# When file system pops up, default directory is opened, and contents displayed.
	Title.text = title
	file_name = file_name.trim_suffix(" (*)")
	FileLineEdit.text = str(file_name, ".txt")
	popup()
	print("[FileSystem] File system opened")
	dir_contents(Global.default_open_dir, dummy_root)


func _on_MainEditorPanel_open_FileSystem_load(title):
	Title.text = title
	ButtonSave.text = "Load"
	popup()
	print("[FileSystem] File system opened")
	dir_contents(Global.default_open_dir, dummy_root)


func _on_MainEditorPanel_save_file_on_path(tab, path):
	var file_name = Global.script_MainEditorPanel.tab_windows_array[tab].file_name
	save_file(tab, file_name, path, true)


func _on_RenameDialogBox_set_dir_name(new_name):
	# create_dir(...) returns path to the new created folder. If folder already exists,
	# or there is any error, previous path is returned.
	current_file_path = create_dir(current_file_path, new_name)
	PathLineEdit.text = current_file_path
	dir_contents(current_file_path, dummy_root)


func _on_TimerERROR_timeout():
	ERROR.text = ""


func dir_contents(path : String, root : Object) -> void:
	# Take a look at the URL at the top of the code.
	
	# This converts array of strings into single string.
	var dir = Directory.new()
	var error = dir.open(path)
	
	# If no error:
	if error == OK:
		FileTree.clear()
		current_file_path = path
		dir.list_dir_begin()
		var file_name = dir.get_next()
		# While there is something in the directory:
		while file_name != "":
			
			# Checks if the current element is a directory.
			if dir.current_is_dir():
				#print("[FileSystem] - Found directory: " + file_name)
				var item = FileTree.create_item(root)
				item.set_text(0, file_name)
				item.set_icon(0, Global.ico_folder)
			
			# If not directory, then a file.
			else:
				#print("[FileSystem] - Found file: " + file_name)
				var item = FileTree.create_item(root)
				item.set_text(0, file_name)
				item.set_icon(0, Global.ico_file)
			
			file_name = dir.get_next()
	
	# If error exists:
	else:
		print("[FileSystem] ERROR: An error occurred when trying to access the path.")
		display_error("An error occurred when trying to access the path.")
		current_file_path = trim_path(path)
		print("[FileSystem] Current path: ", current_file_path)


func get_selected_item() -> int:
	# Returns an object where the mouse is located or something.
	var item = FileTree.get_item_at_position(FileTree.get_local_mouse_position())
	return item


func trim_path(path : String) -> String:
	# Rremoves the last item and slash from the filepath.
	# Usefull if we move back through the file tree.
	var strng = path.get_file()
	var pos = path.find_last("/")
	
	if pos != -1 and path.count("/", 0, 0) >= 2:
		path.erase(pos, strng.length() + 1)
	elif pos != -1:
		path.erase(pos + 1, strng.length())
	else:
		print("[FileSystem] ERROR: path can not be trimed!")
		# Adds '/' at the end of 'C:', so it doesn't do some funky stuff.
		path = path.insert(path.length(), "/")
	
	return path


func add_to_path(path: String, dir : String) -> String:
	# If '/' is already at the end of the path, it doesn't add it.
	if path.find_last("/") == path.length() - 1:
		path = str(path, dir)
	else:
		path = str(path, "/", dir)
	return path


func create_dir(path : String, dir_name : String) -> String:
	# I think this one is quite obvious what it does.
	var dir = Directory.new()
	var new_path = add_to_path(path, dir_name)
	if not dir.dir_exists(new_path):
		var error = dir.make_dir(new_path)
		if error:
			print("[FileSystem] ERROR: error creating directory")
			display_error("Error creating directory!")
			return path
		else:
			print("[FileSystem] New directory '", dir_name, "' created successfuly")
			return new_path
	else:
		print("[FileSystem] Directory already exists!")
		display_error("Directory already exists!")
		return path


func save_file(tab : int, file_name: String, path : String, ex_pass = false) -> void:
	# Source: https://godotengine.org/qa/16555/how-to-create-a-file-in-godot
	# Another source:
	# https://www.davidepesce.com/2019/11/04/essential-guide-to-godot-filesystem-api/
	var main = Global.script_MainEditorPanel
	
	if file_name == "":
		file_name = main.tabs.get_tab_title(tab)
		print("[FileSystem] - Save file name used: '", file_name, "'")
	
	var text = main.tab_windows_array[tab].get_child(1).text
	var file = File.new()
	
	if file.file_exists(path) and ex_pass == false:
		print("[FileSystem] - file on path: ", path, " exists")
		# It popups up a dialog.
		FileExistsPopup.popup()
		valid = false
	
	else:
		if ex_pass == false:
			print("[FileSystem] - file on path ", path, " does not exist")
		var error = file.open(path, File.WRITE)
		if error == OK:
			file.store_string(text)
			main.tab_windows_array[tab].is_saved = true
			main.tab_windows_array[tab].save_path = path
			main.tab_windows_array[tab].file_name = file_name
			print("[FileSystem] Project saved (hopefully)")
			valid = true
		else:
			print("[FileSystem] ERROR: an error occurred while trying to save the file!")
			print("[FileSystem] - Save path used: ", path)
			print("[FileSystem] - Current file path: ", current_file_path)
			display_error("An error occurred while trying to save the file!")
			valid = false
		
	file.close()


func load_file(path: String) -> String:
	# Source: https://godotengine.org/qa/16555/how-to-create-a-file-in-godot
	# Another source:
	# https://www.davidepesce.com/2019/11/04/essential-guide-to-godot-filesystem-api/
	
	var file_content : String = ""
	var file = File.new()
	if !file.file_exists(path):
		print("[FileSystem] ERROR: Cannot load. File does not exist!")
		display_error("Cannot load. File does not exist!")
		valid = false
	else:
		var error = file.open(path, File.READ)
		if error == OK:
			file_content = file.get_as_text()
			print("[FileSystem] File ", path, " loaded")
			valid = true
		else:
			print("[FileSystem] ERROR: an error occurred while trying to load the file!")
			display_error("An error occurred while trying to load the file!")
			valid = false
		
		file.close()
	return file_content


func display_error(error : String) -> void:
	TimerERROR.start(5)
	ERROR.text = error



