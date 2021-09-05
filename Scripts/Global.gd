extends Node

# Basisi for this script: 
# https://godotengine.org/qa/46747/connecting-signal-from-another-scene
# It is automaticaly loaded in Project -> Project Settings -> Auto Load.

# Dictionary, where all the preferences are packed in (see pack_preferences()).
var preferences = {}
var preferences_save_path : String = "user://Preferences.dat"

# Preferences here:
# General
onready var default_project_name : String = "New Project"
onready var default_new_dir_name : String = "New Folder"
onready var default_open_dir : String = "C:/Users"
onready var theme : int = 0
# Editor
onready var highlight_line : bool = false
onready var show_line_numbers : bool = false
onready var draw_tabs : bool = true
onready var tab_close_display : bool = true
onready var show_minimap : bool = false
onready var tab_align : int = 0

# These variables are used, so that scripts connect to them and so they can reach
# each other.
var script_MainEditorPanel


func pack_preferences() -> Dictionary:
	# Packs variables into one dictionary.
	preferences = {
		"default_project_name" : default_project_name,
		"default_new_dir_name" : default_new_dir_name,
		"default_open_dir" : default_open_dir,
		"theme" : theme,
		
		"highlight_line" : highlight_line,
		"show_line_numbers" : show_line_numbers,
		"draw_tabs" : draw_tabs,
		"tab_close_display" : tab_close_display,
		"show_minimap" : show_minimap,
		"tab_align" : tab_align
	}
	
	return preferences


func load_preferences() -> void:
	# Loads the file where preferences dictionary is saved.
	var file = File.new()
	if file.file_exists(preferences_save_path):
		var error = file.open(preferences_save_path, file.READ)
		if error == OK:
			
			# 'data' is 'preferences' dictionary saved in the file.
			# We can read preferences from it.
			var data = file.get_var()
			default_project_name = data.get("default_project_name", "New Project")
			default_new_dir_name = data.get("default_new_dir_name", "New Folder")
			default_open_dir = data.get("default_open_dir", "C:/Users")
			theme = data.get("theme", 0)
			
			highlight_line = data.get("highlight_line", false)
			show_line_numbers = data.get("show_line_numbers", false)
			draw_tabs = data.get("draw_tabs", true)
			tab_close_display = data.get("tab_close_display", true)
			show_minimap = data.get("show_minimap", false)
			tab_align = data.get("tab_align", 0)
			print("[Global] Preferences loaded")
		
		else:
			print("[Global] ERROR loading prefrences: ", error)
	else:
		print("[Global] Preferences not set, default used")


func _ready():
	print("[Global] loaded")
	load_preferences()
	
	# This maximizes the program when it is loaded.
	OS.window_maximized = true


