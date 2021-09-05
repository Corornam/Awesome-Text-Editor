# For more about this 'tool', se '_ready()'.
tool
extends Control


onready var tabs : Node = $TabContainer/Tabs
onready var Confirmtion : Node = $ConfirmationDialog
onready var tab_windows_array : Array

signal open_Preferences()
signal open_RenameDialogBox(title, placeholder)
signal open_R_TabMenu_box()
signal open_FileSystem_save(file_name)
signal open_FileSystem_load()
signal save_file_on_path(tab, path)


func _on_Tabs_tab_clicked(tab):
	print("[MainEditorPanel] tab ", tab, " clicked")
	swich_tab(tab)


func _on_Tabs_tab_close(tab):
	print("[MainEditorPanel] tab close selected")
	swich_tab(tab)
	close_tab(tab)


func _on_Tabs_gui_input(event):
	# When the tab is right clicked...
	var tab : int
	if event.is_action_pressed("ui_mouse_right", false):
		for i in tabs.get_tab_count():
			if tabs.get_tab_rect(i).has_point(event.position):
				print("[MainEditorPanel] Tab ", i, " right clicked")
				tab = i
				emit_signal("open_R_TabMenu_box")
				# Tab swiched to the right clicked one
				swich_tab(tab)
				tabs.current_tab = tab


func _on_RenameDialogBox_set_project_name(new_name):
	print("[MainEditorPanel] Project renamed to: '", new_name, "'")
	# When the name is set and TabRenameDialogBox closes: we rename the current tab.
	tabs.set_tab_title(tabs.current_tab, new_name)


func _on_FileSystem_return_loaded_file(text, project_name, path):
	new_tab(project_name)
	tab_windows_array[tabs.current_tab].is_saved = true
	tab_windows_array[tabs.current_tab].save_path = path
	tab_windows_array[tabs.current_tab].get_child(1).text = text


func _on_ConfirmationDialog_confirmed():
	# Sets active tab to saved, so it can be closed.
	var tab = tabs.current_tab
	tab_windows_array[tab].is_saved = true
	close_tab(tab)


func _on_PreferencesMenu_set_preferences():
	# Sets preferences when they are changed.
	set_preferences()


func _on_Project_item_pressed(ID):
	# Signal from "Project" (MebuButton). Emited, when one of the menu buttons is pressed.
	# ID coresponds to the id of the button.
	match ID:
		# If you are editing the menu, dont forget to fix numbers here and in R_TabMenu.
		
		0:
			print("[MainEditorPanel] 'New Project' selected")
			emit_signal("open_RenameDialogBox", "New project name:",
				Global.default_project_name)
			new_tab(Global.default_project_name)
		
		2:
			print("[MainEditorPanel] 'Load' selected")
			emit_signal("open_FileSystem_load")
		
		4:
			print("[MainEditorPanel] 'Save' selected")
			var path = tab_windows_array[tabs.current_tab].save_path
			if path == "":
				print("[MainEditorPanel] Selected project has not yet been saved")
				emit_signal("open_FileSystem_save",
					tabs.get_tab_title(tabs.current_tab))
			else:
				print("[MainEditorPanel] Selected project has a save path")
				emit_signal("save_file_on_path", tabs.current_tab, path)
		
		5:
			print("[MainEditorPanel] 'Save As...' selected")
			emit_signal("open_FileSystem_save",
				tabs.get_tab_title(tabs.current_tab))
		
		7:
			print("[MainEditorPanel] 'Close Project' selected")
			close_tab(tabs.current_tab)
		
		8:
			print("[MainEditorPanel] 'Quit' selected")
			get_tree().quit()


func _on_Tools_item_pressed(ID):
	# For more info, see '_on_Project_item_pressed' method.
	match ID:
		
		0:
			print("[MainEditorPanel] 'Rename Project' selected")
			emit_signal("open_RenameDialogBox", "Project Name:",
				Global.default_project_name)
		
		2:
			print("[MainEditorPanel] 'Preferences' selected")
			emit_signal("open_Preferences")


func new_tab(tab_name : String) -> void:
	tabs.add_tab(tab_name)
	# Makes new tab current
	tabs.current_tab = tabs.get_tab_count() - 1
	var w = preload("res://Scenes/TabWindow.tscn").instance()
	# We add copied tab window, add it to the array and make it visible
	$PanelContainer.add_child(w, true)
	tab_windows_array.append(w)
	for i in range(tab_windows_array.size()):
		tab_windows_array[i].visible = false
	w.visible = true
	# This is here, so that new tabs have the right preferences set.
	set_preferences()
	print("[MainEditorPanel] New tab '", tab_name, "' created")


func close_tab(tab : int) -> void:
	
	if tab_windows_array[tab].is_saved == false:
		Confirmtion.popup()
	else:
		
		# Can close only if more tabs tahn one.
		if tabs.get_tab_count() > 1:
			tabs.remove_tab(tab)
			# Deletes the scene instance.
			tab_windows_array[tab].queue_free()
			# Removes it from the array.
			tab_windows_array.remove(tab)
			# Makes right tab visible.
			tab_windows_array[tabs.current_tab].visible = true
			print("[MainEditorPanel] Tab ", tab, " closed")
		
		# If there is only one tab and it is closed, the whole software closed.
		else:
			print("[MainEditorPanel] Last tab closed, shutting down...")
			get_tree().quit()


func swich_tab(tab : int) -> void:
	tabs.current_tab = tab
	# Makes all tab windows invisible, except selected one.
	for i in range(tab_windows_array.size()):
		if i != tab:
			tab_windows_array[i].visible = false
	# Selected window visible.
	tab_windows_array[tab].visible = true


func set_preferences() -> void:
	# Here are all the settings that are to be changed. Well, that sounds confusing.
	for i in tab_windows_array.size():
		tab_windows_array[i].get_child(1).highlight_current_line = Global.highlight_line
		tab_windows_array[i].get_child(1).show_line_numbers = Global.show_line_numbers
		tab_windows_array[i].get_child(1).draw_tabs = Global.draw_tabs
		if Global.tab_close_display == true:
			tabs.tab_close_display_policy = tabs.CLOSE_BUTTON_SHOW_ALWAYS
		else:
			tabs.tab_close_display_policy = tabs.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
		tab_windows_array[i].get_child(1).minimap_draw = Global.show_minimap
		if Global.tab_align == 0:
			tabs.tab_align = tabs.ALIGN_LEFT
		elif Global.tab_align == 1:
			tabs.tab_align = tabs.ALIGN_CENTER
		elif Global.tab_align == 2:
			tabs.tab_align = tabs.ALIGN_RIGHT


func _ready():
	# This runs normaly:
	if not Engine.editor_hint:
		# Connecting with 'Global' script for signals between scenes.
		Global.script_MainEditorPanel = self
		# default_project_name is the name for the first tab, when the program is opened.
		new_tab(Global.default_project_name)
	#This runs onnly in the editor. For easier editing. 
	if Engine.editor_hint:
		tabs.add_tab("test tab")



