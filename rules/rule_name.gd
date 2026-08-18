class_name DragableRuleNameEdit
extends LineEdit


var dragable_ref = preload("res://rules/dragable_rule_ref.tscn")
var mouse_over = false
var click_count = 0
var elapsed_time = 0
var dragging = false
const dragtime = .3
var drag_timer = 0

var drag_start_pos:= Vector2.ZERO
var rule_combo:RuleCombo
var drag_layer:Control

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    if click_count > 0:
        elapsed_time+=delta
        if click_count >= 2:
            elapsed_time = 0
            click_count = 0
            selecting_enabled = true
            editable = true
        if elapsed_time > .3:
            click_count-=1
            elapsed_time = 0
    if dragging:
        drag_timer += delta
        if drag_timer >= dragtime:
            print("create")
            var drag_ref = dragable_ref.instantiate()
            drag_layer.add_child(drag_ref)
            drag_ref.setup(rule_combo, true)
            drag_timer = 0
            dragging = false
    

func setup(new_rule_combo:RuleCombo, new_drag_layer:Control):
    rule_combo = new_rule_combo
    drag_layer = new_drag_layer
    text = rule_combo.combo_name


func _gui_input(event: InputEvent) -> void:
    print("input")
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                print("dragging")
                dragging = true
            elif mouse_over:
                click_count += 1
                print("click")
                
    if event is InputEventMouseMotion:
        if dragging and Input.is_action_pressed("click"):
            print("waiting")
        else:
            dragging = false
            drag_timer = 0
            
        

func _on_mouse_entered() -> void:
    mouse_over = true


func _on_mouse_exited() -> void:
    mouse_over = false
    if dragging:
        print("create")
        var drag_ref = dragable_ref.instantiate()
        drag_layer.add_child(drag_ref)
        drag_ref.setup(rule_combo, true)
        drag_timer = 0
        dragging = false


func _on_focus_exited() -> void:
    selecting_enabled = false
    editable = false

func _on_text_submitted(new_text: String) -> void:
    rule_combo.combo_name = new_text
    selecting_enabled = false
    editable = false
    release_focus()
