extends Control

signal map_selected(path: String)
signal load_data
signal save_data
signal save_path(path: String)

@onready var file_dialog: FileDialog = $FilePngDialog
@onready var save_file_load_dialog: FileDialog = $FileLoadDialog
@onready var save_file_dialog: FileDialog = $SaveFileDialog

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func _on_file_dialog_file_selected(path: String) -> void:
    map_selected.emit(path)

func _on_button_pressed() -> void:
    file_dialog.popup_file_dialog()

func _on_save_button_pressed() -> void:
    print("pressed")
    save_data.emit()

func _on_load_button_pressed() -> void:
    save_file_load_dialog.popup_file_dialog()

func _on_file_load_dialog_file_selected(path: String) -> void:
    load_data.emit(path)


func _on_save_file_dialog_file_selected(path: String) -> void:
    save_path.emit(path)
