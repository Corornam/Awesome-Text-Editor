extends MenuButton
# Source: https://godotengine.org/qa/15934/how-to-use-popupmenu-from-menubutton


onready var popup = get_popup()


func _ready():
	# Setting up shortcuts. For more, see comments in 'ProjectMenuButton' script.
	for idx in popup.get_item_count():
		if popup.get_item_text(idx) == "Rename Project":
			popup.set_item_shortcut(idx,
				load("res://Resources/Shortcut_ctrl+r.tres"), true)
	
	popup.connect("id_pressed", Global.script_MainEditorPanel,
		"_on_Tools_item_pressed")
