class_name RuleData
extends RefCounted

var rule_name: String = ""
var children: Array[RuleData] = []
var args: Dictionary = {}
var options: Array = []

func is_combinator() -> bool:
    return rule_name == "And" or rule_name == "Or"

func to_dict() -> Dictionary:
    var d := {"rule": rule_name, "options": options}
    if is_combinator():
        var kids: Array = []
        for c in children:
            kids.append(c.to_dict())
        d["children"] = kids
    else:
        d["args"] = args
    return d

static func from_dict(data: Dictionary) -> RuleData:
    var node := RuleData.new()
    node.rule_name = data.get("rule", "")
    node.options = data.get("options", [])
    if data.has("children"):
        for c in data["children"]:
            node.children.append(RuleData.from_dict(c))
    else:
        node.args = data.get("args", {})
    return node
