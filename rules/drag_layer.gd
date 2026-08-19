class_name DragLayer
extends Control

var hovered_entrance: Entrance
var hovered_rule_spot: RuleSpot
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
    
func update_entrance(entrance:Entrance):
    hovered_entrance = entrance

func update_rule_spot(rule_spot:RuleSpot):
    hovered_rule_spot = rule_spot
