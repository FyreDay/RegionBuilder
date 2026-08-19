class_name RuleSpot
extends PanelContainer

@export var drag_layer:Control

signal is_hovered(RuleSpot)

var hovered := false
var rule_data:DragableRuleData  

func _ready() -> void:
    if drag_layer:
        is_hovered.connect(drag_layer.update_rule_spot)
    _update_style()

func _on_mouse_entered() -> void:
    hovered = true
    _update_style()
    is_hovered.emit(self)

func setup(new_drag_layer:Control):
    if not drag_layer:
        drag_layer = new_drag_layer
        is_hovered.connect(drag_layer.update_rule_spot)
        

func _on_mouse_exited() -> void:
    hovered = false
    _update_style()
    is_hovered.emit(self)
    
func set_rule(new_rule_data:DragableRuleData):
    rule_data = new_rule_data  
    rule_data.reparent(self)
    is_hovered.emit(null)
    if is_hovered.is_connected(drag_layer.update_rule_spot):
        is_hovered.disconnect(drag_layer.update_rule_spot)
    print("rule_data")
    redraw()

func redraw():
    _update_style()
    queue_redraw()

func _update_style() -> void:
    if rule_data == null:
        var style := StyleBoxFlat.new()

        style.bg_color = Color(0.12, 0.12, 0.12, 1.0)
        style.border_width_left = 1
        style.border_width_right = 1
        style.border_width_top = 1
        style.border_width_bottom = 1

        style.border_color = Color.WHITE if hovered else Color(0.35, 0.35, 0.35)

        style.corner_radius_top_left = 8
        style.corner_radius_top_right = 8
        style.corner_radius_bottom_left = 8
        style.corner_radius_bottom_right = 8

        add_theme_stylebox_override("panel", style)
    else:
        print("remove")
        remove_theme_stylebox_override("panel")
        
