class_name DragableRuleData
extends VBoxContainer

@onready var name_ref: LineEdit = $Rule/NameRef
@onready var rule_children: VBoxContainer = $RuleChildren
@onready var rule_args: HBoxContainer = $Rule/Args

var rule_arg = preload("res://rules/rule_arg.tscn")

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
        var drag_layer = get_parent() as DragLayer
        if drag_layer.hovered_rule_spot == null:
            queue_free()
            return
        drag_layer.hovered_rule_spot.set_rule(self)
        dragging = false
        

func setup(custom_rule:CustomRule, is_dragging):
    rule_data = RuleData.new()
    rule_data.rule = custom_rule
    dragging = is_dragging
    name_ref.text = custom_rule.rule_name
    for key in custom_rule.arg_name_to_type:
        var new_arg = rule_arg.instantiate()
        rule_args.add_child(new_arg)
        new_arg.setup(key,custom_rule.arg_name_to_type[key])
