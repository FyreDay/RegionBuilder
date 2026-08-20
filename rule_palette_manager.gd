class_name RulePaletteManager
extends VBoxContainer

var dragable_rule = preload("res://rules/Dragable_Rule.tscn")
@onready var new_rule_combo_button: Button = $New

@onready var ui:LogicUI = $"../../../.."
func save_data() -> Array:
    var list := []
    for c in get_children():
        if c is DragableRuleNameEdit:
            list.append(c.rule_combo.to_dict())
    return list
    
func load_data(data: Dictionary, rule_manager, _drag_layer):
    var combos = data.get("rule_combos", [])
    for rule in combos:
        create_new_combo(RuleCombo.from_dict(rule, rule_manager))
        
        
func get_rule_combo(rule_name:String) -> RuleCombo:
    for c in get_children():
        if c is DragableRuleNameEdit:
            if c.rule_combo.combo_name == rule_name:
                return c.rule_combo
    return null
        

func create_new_combo(rule:RuleCombo):
    var new_dragable_combo = dragable_rule.instantiate()
    add_child(new_dragable_combo)
    new_dragable_combo.setup(rule, ui.drag_layer)
    new_dragable_combo.selected.connect(ui._on_rule_combo_selected)
    ui.rule_builder_toggled.connect(new_dragable_combo.on_rule_builder_state)
    new_dragable_combo.on_rule_builder_state(ui.rule_builder_open)
    move_child(new_rule_combo_button, get_child_count() - 1)

func _on_new_pressed() -> void:
    var rule_combo = RuleCombo.new()
    rule_combo.combo_name = "Rule " + str(get_child_count())
    create_new_combo(rule_combo)
