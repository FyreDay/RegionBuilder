class_name RuleManager
extends VBoxContainer

var dragable_custom_rule = preload("res://rules/dragable_custom_rule.tscn")

func save_data() -> Array:
    var list := []
    for c in get_children():
        if c is DragableCustomRule:
            if not c.custom_rule.editable:
                continue
            list.append(c.custom_rule.to_dict())
    return list
    
func load_data(data: Dictionary, drag_layer):
    var custom_rules = data.get("custom_rules", [])
    for rule in custom_rules:
        var new_dcr = dragable_custom_rule.instantiate()
        add_child(new_dcr)
        new_dcr.setup(CustomRule.from_dict(rule), drag_layer)
        
func get_custom_rule(rule_name:String) -> CustomRule:
    for c in get_children():
        if c is DragableCustomRule:
            if c.custom_rule.rule_name == rule_name:
                return c.custom_rule
    return null
        
    
