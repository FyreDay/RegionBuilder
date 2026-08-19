@tool
class_name CustomRuleArgumentDefinition
extends Resource

enum RuleArgType {
    STRING,
    INT,
    FLOAT,
    BOOL,
    STRING_LIST,
    RULE_LIST
}

@export var arg_name: String

@export_enum("STRING", "INT", "FLOAT", "BOOL", "STRING_LIST", "RULE_LIST") var arg_type: int = RuleArgType.STRING:
    set(value):
        if arg_type != value:
            arg_type = value
            _reset_default_value()
            notify_property_list_changed()

var default_value: Variant = ""


func _get_property_list() -> Array[Dictionary]:
    var properties: Array[Dictionary] = []
    
    var type_to_assign: int = TYPE_STRING
    match arg_type:
        RuleArgType.STRING:
            type_to_assign = TYPE_STRING
        RuleArgType.INT:
            type_to_assign = TYPE_INT
        RuleArgType.FLOAT:
            type_to_assign = TYPE_FLOAT
        RuleArgType.BOOL:
            type_to_assign = TYPE_BOOL
        RuleArgType.STRING_LIST:
            type_to_assign = TYPE_ARRAY
        RuleArgType.RULE_LIST:
            type_to_assign = TYPE_ARRAY

    properties.append({
        "name": "default_value",
        "type": type_to_assign,
        "usage": PROPERTY_USAGE_DEFAULT,
        "hint": PROPERTY_HINT_NONE
    })
    
    return properties


func _reset_default_value() -> void:
    match arg_type:
        RuleArgType.STRING:
            default_value = ""
        RuleArgType.INT:
            default_value = 0
        RuleArgType.FLOAT:
            default_value = 0.0
        RuleArgType.BOOL:
            default_value = false
        RuleArgType.STRING_LIST:
            default_value = []
        RuleArgType.RULE_LIST:
            default_value = []
