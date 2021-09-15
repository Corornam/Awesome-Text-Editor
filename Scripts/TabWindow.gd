extends Control


onready var text : Node = $TextEdit
onready var is_saved : bool = true
onready var save_path : String = ""
onready var file_name : String = ""
onready var main = Global.script_MainEditorPanel
var array_pos : int


func _on_Timer_timeout():
	# Places '(*)' if file is not saved.
	var win_array : Array = main.tab_windows_array
	array_pos =  win_array.find(self, 0)
	if is_saved == false:
		if main.tabs.get_tab_title(array_pos).count("(*)", 0, 0) == 0:
			main.tabs.set_tab_title(array_pos,
				str(main.tabs.get_tab_title(array_pos), " (*)"))
	else:
		if main.tabs.get_tab_title(array_pos).count("(*)", 0, 0) >= 1:
			var trimmed = main.tabs.get_tab_title(array_pos).trim_suffix(" (*)")
			main.tabs.set_tab_title(array_pos, trimmed)


func _on_TextEdit_text_changed():
	is_saved = false


func _enter_tree():
	print("[TabWindow] New tab window entered tree")



