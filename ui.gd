extends Control

@onready var file_dialog: FileDialog = $FilePngDialog
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

signal map_selected(path: String)


func _on_file_dialog_file_selected(path: String) -> void:
    map_selected.emit(path)


func _on_button_pressed() -> void:
    file_dialog.popup_file_dialog()
