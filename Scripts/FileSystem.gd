#----------------------------------------------------------------------------------------
# Awesome Text Editor
# https://github.com/grabaraba/Awesome-Text-Editor
# Under Apache-2.0 License
#----------------------------------------------------------------------------------------


# Source: https://godotengine.org/qa/16555/how-to-create-a-file-in-godot
# Another source:
# https://www.davidepesce.com/2019/11/04/essential-guide-to-godot-filesystem-api/
extends FileDialog


signal return_loaded_file(text, project_name, path)


func _on_Editor_open_FileSystem_load():
	self.popup()
	self.mode = 0	# Open file
	self.current_dir = Global.default_open_dir


func _on_Editor_open_FileSystem_save(file_name):
	self.popup()
	self.mode = 4	# Save file
	self.current_dir = Global.default_open_dir
	self.current_file = file_name.trim_suffix(" (*)")


func _on_FileSystem_file_selected(path):
	print("[FileSystem] File on path ", path, " selected")
	match mode:
		0:
			var text : String = load_file(path)
			emit_signal("return_loaded_file", text, current_file, path)
		4:
			save_file(Global.script_MainEditorPanel.tabs.current_tab, current_file, path)
	

func _on_Editor_save_file_on_path(tab, path):
	var file_name = Global.script_MainEditorPanel.tab_windows_array[tab].file_name
	save_file(tab, file_name, path)


func load_file(path: String) -> String:
	
	var file_content : String = ""
	var file = File.new()
	var error = file.open(path, File.READ)
	if error == OK:
		file_content = file.get_as_text()
		print("[FileSystem] File ", path, " loaded")
	else:
		print("[FileSystem] ERROR: an error occurred while trying to load the file!")
	
	file.close()
	return file_content


func save_file(tab : int, file_name : String, path : String) -> void:
	var main = Global.script_MainEditorPanel
	
	if file_name == "":
		file_name = main.tabs.get_tab_title(tab)
		print("[FileSystem] - Save file name used: '", file_name, "'")
	
	var text = main.tab_windows_array[tab].get_child(1).text
	var file = File.new()
	var error = file.open(path, File.WRITE)
	if error == OK:
		file.store_string(text)
		main.tab_windows_array[tab].is_saved = true
		main.tab_windows_array[tab].save_path = path
		main.tab_windows_array[tab].file_name = file_name
		print("[FileSystem] Project saved (hopefully)")
	else:
		print("[FileSystem] ERROR: an error occurred while trying to save the file!")
		print("[FileSystem] - Save path used: ", path)
	
	file.close()



