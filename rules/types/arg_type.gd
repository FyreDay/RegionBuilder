class_name ArgType
extends RefCounted

var arg_type: CustomRuleArgumentDefinition.RuleArgType
var default_value 
    
func to_dict() -> Dictionary:
    var d := {"arg_type": arg_type, "default_value": default_value}
    return d

static func from_dict(data: Dictionary) -> ArgType:
    var at = ArgType.new()
    at.arg_type = data.get("arg_type", CustomRuleArgumentDefinition.RuleArgType.STRING)
    at.default_value = data.get("default_value")
    return at
    
