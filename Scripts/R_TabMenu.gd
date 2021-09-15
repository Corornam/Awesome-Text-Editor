#----------------------------------------------------------------------------------------
# Awesome Text Editor
# https://github.com/grabaraba/Awesome-Text-Editor
# Under Apache-2.0 License
#----------------------------------------------------------------------------------------



extends PopupMenu


# Node connections
onready var in_project : Node = get_parent().get_node("ToolBar/Project").popup
onready var in_Tools : Node = get_parent().get_node("ToolBar/Tools").popup


func _on_MainEditorPanel_open_R_TabMenu_box():
	# Here the mennu is opened.
	print("[R_TabMenu] opened")
	self.set_global_position(get_global_mouse_position())
	popup()


func _on_id_pressed(ID):
	# It simply emits signals from item in toolbar. Makes things more simple.
	match ID:
		0:
			print("[R_TabMenu] 'Save' selected")
			in_project.emit_signal("id_pressed", 4)
			self.hide()
		1:
			print("[R_TabMenu] 'Rename' selected")
			in_Tools.emit_signal("id_pressed", 0)
			self.hide()
		2:
			print("[R_TabMenu] 'Close' selected")
			in_project.emit_signal("id_pressed", 7)
			self.hide()


func _ready():
	# Connects signal with itself. Error check is here only becouse connect() return
	# a value, and if i dont use it, it bugs me with a warning.
	# Could also be done like this:
	#assert(get_tree().connect("peer_connected", self, "_peer_connected") == 0)
	var error = connect("id_pressed", self, "_on_id_pressed")
	if error != 0:
		print("[R_TabMenu] ERROR: ", error)

