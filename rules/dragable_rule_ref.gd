extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

var dragging:bool
var rule_combo:RuleCombo
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    print("process")
    if not dragging:
        return
    print("dragging")
    position = get_parent().get_local_mouse_position()
    queue_redraw()

    if not Input.is_action_pressed("click"):
        dragging = false

func setup(new_rule_combo:RuleCombo, is_dragging):
    print("create")
    rule_combo = new_rule_combo
    dragging = is_dragging
#
func _on_name_ref_gui_input(event: InputEvent) -> void:
    pass
    #if dragging:
        #print("dragging")
        #if event is InputEventMouseButton:
            #if event.button_index == MOUSE_BUTTON_LEFT:
                #if not event.pressed:
                    #dragging = false
                    #return
                    #
        #if event is InputEventMouseMotion and Input.is_action_pressed("click"): 
                #var mouse_pos := get_global_mouse_position()
                #position = mouse_pos
                #queue_redraw()
                #get_viewport().set_input_as_handled()
