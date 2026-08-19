class_name RuleCombo
extends RefCounted

signal changed

var combo_name: String
var root: RuleData

func set_combo_name(new_name: String) -> void:
    combo_name = new_name
    changed.emit()

func to_dict() -> Dictionary:
    return {}


static func from_dict(data: Dictionary) -> RuleData:
    return null
