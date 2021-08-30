extends MenuButton
# Source: https://godotengine.org/qa/15934/how-to-use-popupmenu-from-menubutton


onready var popup = get_popup()


func _ready():
	# This is for setting up shortcuts. It is set up according to the button name,
	# so that even if ID is changed, this still works.
	for idx in popup.get_item_count():
		if popup.get_item_text(idx) == "Save":
			popup.set_item_shortcut(idx,
				load("res://Resources/Shortcut_ctrl+s.tres"), true)
		elif popup.get_item_text(idx) == "Save As":
			popup.set_item_shortcut(idx,
				load("res://Resources/Shortcut_shft+alt+s.tres"), true)
		elif popup.get_item_text(idx) == "Load":
			popup.set_item_shortcut(idx,
				load("res://Resources/Shortcut_ctrl+l.tres"), true)
		elif popup.get_item_text(idx) == "New Project":
			popup.set_item_shortcut(idx,
				load("res://Resources/Shortcut_ctrl+n.tres"), true)
		elif popup.get_item_text(idx) == "Close Project":
			popup.set_item_shortcut(idx,
				load("res://Resources/Shortcut_ctrl+q.tres"), true)
	
	popup.connect("id_pressed", Global.script_MainEditorPanel,
		"_on_Project_item_pressed")
