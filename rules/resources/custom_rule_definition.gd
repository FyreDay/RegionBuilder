class_name CustomRuleDefinition
extends Resource

@export var rule_name: String
@export var arguments: Array[CustomRuleArgumentDefinition] = []
@export var is_combinator: bool

func get_data():
    var new = CustomRule.new()
    new.editable = false
    new.is_combinator = is_combinator
    new.rule_name = rule_name
    for arg in arguments:
        var arg_type = ArgType.new()
        arg_type.arg_type = arg.arg_type
        arg_type.default_value = arg.default_value
        new.arg_definitions[arg.arg_name] = arg_type
    return new
