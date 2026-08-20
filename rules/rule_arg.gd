class_name RuleArg
extends HBoxContainer

@onready var label: Label = $Label
@onready var text_value: LineEdit = $StringValue
@onready var number_value: SpinBox = $IntValue
@onready var bool_value: CheckBox = $BoolValue

var arg_name
var rule_data: RuleData

func setup(new_arg_name: String, definition: ArgType, value, new_rule_data:RuleData) -> void:
    arg_name = new_arg_name
    label.text = new_arg_name
    rule_data = new_rule_data
    text_value.hide()
    number_value.hide()
    bool_value.hide()

    match definition.arg_type:
        CustomRuleArgumentDefinition.RuleArgType.STRING:
            text_value.show()
            text_value.text = str(value)

        CustomRuleArgumentDefinition.RuleArgType.INT:
            number_value.show()
            number_value.value = int(value)
        CustomRuleArgumentDefinition.RuleArgType.FLOAT:
            number_value.show()
            number_value.value = float(value)

        CustomRuleArgumentDefinition.RuleArgType.BOOL:
            bool_value.show()
            bool_value.button_pressed = bool(value)
    
        


func _on_string_value_text_changed(new_text: String) -> void:
    rule_data.set_arg(arg_name, new_text)


func _on_int_value_value_changed(value: float) -> void:
    rule_data.set_arg(arg_name, value)


func _on_bool_value_toggled(toggled_on: bool) -> void:
    rule_data.set_arg(arg_name, toggled_on)
