#----------------------------------------------------------------------------------------
# Awesome Text Editor
# https://github.com/grabaraba/Awesome-Text-Editor
# Under Apache-2.0 License
#----------------------------------------------------------------------------------------


extends PopupPanel


# Connections to it's children.
onready var Title : Node = $CenterContainer/Title
onready var LineEditName : Node = $CenterContainer/LineEditName

# This is so the script knows who wants to edit text.
var active_request : String

signal set_project_name(new_name)
signal set_dir_name(new_name)


func _on_MainEditorPanel_open_RenameDialogBox(title, placeholder):
	active_request = "MainEditorPanel"
	Title.text = title
	LineEditName.placeholder_text = placeholder
	popup()
	print("[RenameDialogBox] Dialog opened")


func _on_FileSystem_open_RenameDialogBox(title, placeholder):
	active_request = "FileSystem"
	Title.text = title
	LineEditName.placeholder_text = placeholder
	popup()
	print("[RenameDialogBox] Dialog opened")


func _on_LineEdit_text_entered(new_text):
	# When we press enter, while editing the text.
	
	if active_request == "MainEditorPanel":
		self.hide()
		# If Nothing is entered, Default text is the tab name.
		if new_text == "":
			new_text = Global.default_project_name
		# Return signal to 'MainEditorPanel'.
		emit_signal("set_project_name", new_text)
		print("[RenameDialogBox] New project name set: '", new_text, "'")
	
	elif active_request == "FileSystem":
		self.hide()
		if new_text == "":
			new_text = Global.default_new_dir_name
		emit_signal("set_dir_name", new_text)
		print("[RenameDialogBox] New directory name set: '", new_text, "'")
		
	LineEditName.clear()


func _on_ButtonOK_pressed():
	print("[RenameDialogBox] 'OK' button pressed")
	var new_text = LineEditName.text
	LineEditName.emit_signal("text_entered", new_text)


func _on_ButtonCancel_pressed():
	print("[RenameDialogBox] 'Cancel' button pressed")
	self.hide()
	if active_request == "MainEditorPanel":
		# Closes the tab that was just opened.
		var tab = Global.script_MainEditorPanel.tabs.current_tab
		Global.script_MainEditorPanel.close_tab(tab)




