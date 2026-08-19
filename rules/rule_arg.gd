class_name RuleArg
extends HBoxContainer


@onready var label: Label = $Label
@onready var text_value: LineEdit = $StringValue
@onready var number_value: SpinBox = $IntValue
@onready var bool_value: CheckBox = $BoolValue

func setup(name: String, definition: ArgType) -> void:
    label.text = name

    text_value.hide()
    number_value.hide()
    bool_value.hide()

    match definition.arg_type:
        CustomRuleArgumentDefinition.RuleArgType.STRING:
            text_value.show()
            text_value.text = str(definition.default_value)

        CustomRuleArgumentDefinition.RuleArgType.INT:
            number_value.show()
            number_value.value = int(definition.default_value)
        CustomRuleArgumentDefinition.RuleArgType.FLOAT:
            number_value.show()
            number_value.value = float(definition.default_value)

        CustomRuleArgumentDefinition.RuleArgType.BOOL:
            bool_value.show()
            bool_value.button_pressed = bool(definition.default_value)
