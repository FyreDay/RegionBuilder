class_name DragableRuleData
extends VBoxContainer

@onready var name_ref: LineEdit = $Rule/NameRef
@onready var rule_children: VBoxContainer = $MarginContainer/RuleChildren
@onready var rule_args: HBoxContainer = $Rule/Args
@onready var buttons: HBoxContainer = $MarginContainer/RuleChildren/Buttons

var rule_arg = preload("res://rules/rule_arg.tscn")
var rule_spot = preload("res://rules/rule_spot.tscn")
var drag_layer:DragLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

var dragging:bool
var rule_data: RuleData
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if not dragging:
        return
    position = get_parent().get_local_mouse_position()
    queue_redraw()

    if not Input.is_action_pressed("click"):
        if drag_layer.hovered_rule_spot == null:
            queue_free()
            return
        drag_layer.hovered_rule_spot.set_rule(self)
        dragging = false
        
func setup_with_data(custom_rule:RuleData, new_drag_layer:DragLayer):
    drag_layer = new_drag_layer
    rule_data = custom_rule
    dragging = false
    name_ref.text = rule_data.rule.rule_name
    create_args()
    create_children()

func setup(custom_rule:CustomRule, is_dragging):
    drag_layer = get_parent() as DragLayer
    rule_data = RuleData.new()
    rule_data.rule = custom_rule
    dragging = is_dragging
    name_ref.text = custom_rule.rule_name
    for key in custom_rule.arg_name_to_type:
        rule_data.args[key]=rule_data.rule.arg_name_to_type[key].default_value
    create_args()
    if not rule_data.rule.is_combinator:
        buttons.hide()    

func create_args():
    for key in rule_data.rule.arg_name_to_type:
        var new_arg = rule_arg.instantiate()
        rule_args.add_child(new_arg)
        new_arg.setup(key,rule_data.rule.arg_name_to_type[key], rule_data.args[key], rule_data)

func create_children():
    if rule_data.rule.is_combinator:
        for child_data in rule_data.children:
            var new_spot = rule_spot.instantiate()
            rule_children.add_child(new_spot)
            new_spot.setup(drag_layer, rule_data)
            new_spot.from_rule_data(child_data)
        rule_children.move_child(buttons, rule_children.get_child_count() - 1)
    else:
        buttons.hide()
    

func _on_add_pressed() -> void:
    var new_spot = rule_spot.instantiate()
    rule_children.add_child(new_spot)
    new_spot.setup(drag_layer, rule_data)
    rule_children.move_child(buttons, rule_children.get_child_count() - 1)


func _on_remove_pressed() -> void:
    if rule_children.get_child_count() <= 3:
        return
    var spot = rule_children.get_child(rule_children.get_child_count() - 2)
    if spot.has_rule():
        drag_layer.trigger_dangerous_action((func(): 
            rule_children.remove_child(spot)
            spot.queue_free()
            queue_redraw()
            ), null)
        return
    rule_children.remove_child(spot)
    queue_redraw()
    
    
