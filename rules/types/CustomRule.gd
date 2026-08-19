class_name CustomRule
extends RefCounted

signal changed

var editable = true
var is_combinator = false
var rule_name: String
var arg_name_to_type: Dictionary[String, ArgType] = {}

func set_rule_name(new_name: String) -> void:
    rule_name = new_name
    changed.emit()

func to_dict() -> Dictionary:
    return {}


static func from_dict(data: Dictionary) -> RuleData:
    return null
