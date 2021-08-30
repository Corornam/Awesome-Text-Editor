extends PopupPanel



func _on_About_pressed():
	print("[AboutPopup] opened")
	popup()


func _on_Close_pressed():
	self.hide()
