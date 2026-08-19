extends Control

signal new_rule

var arg_type = preload("res://rules/rule_arg_type.tscn")
var rule_data = preload("res://rules/CustomRule.gd")

@onready var vcontainer: VBoxContainer = $PanelContainer/VBoxParent/VBoxContainer
@onready var rule_name: LineEdit = $PanelContainer/VBoxParent/VBoxContainer/HBoxContainer/RuleName

func _on_button_pressed() -> void:
    vcontainer.add_child(arg_type.instantiate())


func _on_delete_arg_pressed() -> void:
    if vcontainer.get_child_count() > 0:
        var last_index = vcontainer.get_child_count() - 1
        var bottom_child = vcontainer.get_child(last_index)
        if bottom_child is RuleArgType:
            bottom_child.queue_free()


func _on_save_pressed() -> void:
    var rule = rule_data.new()
    rule.rule_name = rule_name.text
    for child in vcontainer:
          if child is RuleArgType:
            rule.arg_names.append(child.arg_name)
            rule.arg_types.append(child.arg_type)
    new_rule.emit()
