extends WindowDialog


onready var DefaultProjectName : Node = $VBoxContainer/OptionsTabs/General/DefaultProjectName/LineEdit
onready var DefaultNewDirName : Node = $VBoxContainer/OptionsTabs/General/DefaultNewDirName/LineEdit
onready var DefaultOpenDir : Node = $VBoxContainer/OptionsTabs/General/DefaultOpenDir/LineEdit
onready var ThemeSelection : Node = $VBoxContainer/OptionsTabs/General/ThemeSelection/OptionButton
onready var HighlightLine : Node = $VBoxContainer/OptionsTabs/Editor/HighlightLine/CheckBox
onready var ShowLineNumbers : Node = $VBoxContainer/OptionsTabs/Editor/ShowLineNumbers/CheckBox
onready var DrawTabs : Node = $VBoxContainer/OptionsTabs/Editor/DrawTabs/CheckBox
onready var TabCloseDisplay : Node = $VBoxContainer/OptionsTabs/Editor/TabCloseDisplay/CheckBox
onready var Minimap : Node = $VBoxContainer/OptionsTabs/Editor/Minimap/CheckBox
onready var TabAlign : Node = $VBoxContainer/OptionsTabs/Editor/TabAlign/CheckBox
onready var ERROR : Node = $ERROR
onready var TimerERR : Node = $Timer

signal set_preferences()


func _on_MainEditorPanel_open_Preferences():
	print("[PreferencesMenu] Opened")
	
	# loading preferences in LineEdit from Global:
	DefaultProjectName.text = Global.default_project_name
	DefaultNewDirName.text = Global.default_new_dir_name
	DefaultOpenDir.text = Global.default_open_dir
	ThemeSelection.selected = Global.theme
	
	HighlightLine.pressed = Global.highlight_line
	ShowLineNumbers.pressed = Global.show_line_numbers
	DrawTabs.pressed = Global.draw_tabs
	TabCloseDisplay.pressed = Global.tab_close_display
	Minimap.pressed = Global.show_minimap
	TabAlign.selected = Global.tab_align
	
	popup()


func _on_ButtonSave_pressed():
	print("[PreferencesMenu] 'Save' selected")
	
	# Checks if entered default open dir path is valid.
	var dir = Directory.new()
	if not dir.dir_exists(DefaultOpenDir.text):
		print("[PreferencesMenu] ERROR: Default open directory: Not valid path!")
		display_error("Default open directory: Not valid directory path!")
		return
	
	# Set values are set in Global.
	Global.default_project_name = DefaultProjectName.text
	Global.default_new_dir_name = DefaultNewDirName.text
	Global.default_open_dir = DefaultOpenDir.text
	Global.theme = ThemeSelection.selected
	
	Global.highlight_line = HighlightLine.pressed
	Global.show_line_numbers = ShowLineNumbers.pressed
	Global.draw_tabs = DrawTabs.pressed
	Global.tab_close_display = TabCloseDisplay.pressed
	Global.show_minimap = Minimap.pressed
	Global.tab_align = TabAlign.selected
	
	# Here, all the settings are saved on a file.
	var file = File.new()
	var content = Global.pack_preferences()
	var error = file.open(Global.preferences_save_path, file.WRITE)
	if error == OK:
		file.store_var(content)
		print("[PreferencesMenu] Preferences saved successfully")
		self.hide()
	else:
		print("[PreferencesMenu] ERROR: ", error)
		display_error(str("ERROR: ", error))
	file.close()
	
	# Loads preferences
	Global.load_preferences()
	emit_signal("set_preferences")


func _on_ButtonCancel_pressed():
	print("[PreferencesMenu] 'Cancel' selected")
	self.hide()


func _on_Timer_timeout():
	# timer from display_error()
	ERROR.text = ""


func _on_set_preferences():
	var node : Node = get_parent().get_parent()
	match Global.theme:
		0:
			print("[PreferencesMenu] 'Default Dark' theme set")
			node.theme = null
		1:
			print("[PreferencesMenu] 'Godot Blue' theme set")
			node.set_theme(load("res://Resources/Themes/GodotBlue.tres"))


func display_error(error : String) -> void:
	# For desplaying errors to the users. Closes after 5 seconds.
	TimerERR.start(5)
	ERROR.text = error


func _ready():
	var error = connect("set_preferences", self, "_on_set_preferences")
	if error != OK:
		print("[PreferencesMenu] ERROR: ", error)
	emit_signal("set_preferences")
