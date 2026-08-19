class_name LogicUI
extends Control

signal map_selected(path: String)
signal load_data
signal save_data
signal save_path(path: String)
signal export_path(dir: String)

@onready var file_dialog: FileDialog = $FilePngDialog
@onready var save_file_load_dialog: FileDialog = $FileLoadDialog
@onready var save_file_dialog: FileDialog = $SaveFileDialog
@onready var export_dialog: FileDialog = $ExportDirDialog

@onready var tool_panel: Panel = $CanvasLayer/Panel
@onready var rule_palette_panel: Panel = $CanvasLayer/PalettePanel
#@onready var rule_builder_panel: Panel = 
#@onready var rule_part_panel: Panel = 
@onready var rule_editor_panel: Panel = $CanvasLayer/RuleEditor
@onready var rule_palette: VBoxContainer = $CanvasLayer/PalettePanel/ScrollContainer/RulePaleteContainer
@onready var drag_layer: DragLayer = $CanvasLayer/DragLayer

var dragable = preload("res://rules/Dragable_Rule.tscn")

var palette_open = false
var rule_builder_open = false

func _ready() -> void:
    var dragable_new = dragable.instantiate()
    var rule_combo = RuleCombo.new()
    rule_combo.combo_name = "This is a test Rule"
    rule_palette.add_child(dragable_new)
    dragable_new.setup(rule_combo,drag_layer)

func _process(delta: float) -> void:
    slide_panel(delta)

func slide_panel(delta):
    var new_pos = Vector2(0,tool_panel.size.y)
    if not palette_open:
        new_pos.x = -rule_palette_panel.size.x
    
    rule_palette_panel.position = rule_palette_panel.position.lerp(new_pos, 10 * delta)
    
    var new_editor_pos = Vector2(tool_panel.size.x,tool_panel.size.y)
    if rule_builder_open:
        new_editor_pos.x = tool_panel.size.x-rule_editor_panel.size.x
    
    rule_editor_panel.position = rule_editor_panel.position.lerp(new_editor_pos, 10 * delta)  


func _on_file_dialog_file_selected(path: String) -> void:
    map_selected.emit(path)

func _on_button_pressed() -> void:
    file_dialog.popup_file_dialog()

func _on_save_button_pressed() -> void:
    save_data.emit()

func _on_load_button_pressed() -> void:
    save_file_load_dialog.popup_file_dialog()

func _on_file_load_dialog_file_selected(path: String) -> void:
    load_data.emit(path)


func _on_save_file_dialog_file_selected(path: String) -> void:
    save_path.emit(path)


func _on_export_button_pressed() -> void:
    export_dialog.popup_file_dialog()


func _on_export_dir_dialog_dir_selected(dir: String) -> void:
    export_path.emit(dir)


func _on_slide_toggle_toggled(toggled_on: bool) -> void:
    palette_open = toggled_on
    if not palette_open:
        rule_builder_open = false
    
func update_entrance(entrance:Entrance):
    drag_layer.update_entrance(entrance)

func _on_rule_builder_toggled(toggled_on: bool) -> void:
    rule_builder_open = toggled_on
