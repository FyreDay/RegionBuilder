class_name RuleData
extends RefCounted

signal changed

var rule:CustomRule
var children: Array[RuleData] = []
var args: Dictionary = {}
var options: Array = []

func set_arg(name: String, value: Variant) -> void:
    args[name] = value
    changed.emit()

func set_option(index: int, value: Variant) -> void:
    options[index] = value
    changed.emit()

func add_child_data(child: RuleData) -> void:
    children.append(child)
    child.changed.connect(_on_child_changed)
    changed.emit()

func remove_child_data(child: RuleData) -> void:
    if child in children:
        children.erase(child)
        if child.changed.is_connected(_on_child_changed):
            child.changed.disconnect(_on_child_changed)
        changed.emit()
        
func _on_child_changed() -> void:
    changed.emit()

func to_dict() -> Dictionary:
    var d := {"rule": rule.rule_name, "options": options}
    if rule.is_combinator:
        var kids: Array = []
        for c in children:
            kids.append(c.to_dict())
        d["children"] = kids
    else:
        d["args"] = args
    return d

static func from_dict(data: Dictionary) -> RuleData:
    var node := RuleData.new()
    var rule_name: String = data.get("rule", "")
    #TODO: Make rule lookup
    #node.rule = rule_lookup[rule_name]
    node.options = data.get("options", [])
    if data.has("children"):
        for c in data["children"]:
            node.children.append(RuleData.from_dict(c))
    else:
        node.args = data.get("args", {})
    return node
