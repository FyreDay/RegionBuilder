extends Control

@onready var name_edit: DragableRuleNameEdit = $RuleName

func _ready() -> void:
    print("ready")
    
func setup(new_rule_combo:RuleCombo, drag_layer:Control):
    print("setup")
    name_edit.setup(new_rule_combo, drag_layer)
