extends Node2D

signal region_popup_opened
signal region_popup_closed

var region_scene = preload("res://region.tscn")
var isDrawingRegion = false
var dragStartMousePos: Vector2
var dragSizeVector: Vector2

var undo_redo := UndoRedo.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    draw_region(delta)
    draw_entrance(delta)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("redo"):
        undo_redo.redo()
        return
    if event.is_action_pressed("undo"):
        undo_redo.undo()
    

func _draw() -> void:
    if isDrawingRegion:
        draw_rect(Rect2(dragStartMousePos, dragSizeVector), Color(1,1,1,.5))
    

func draw_region(delta):
    if !isDrawingRegion and Input.is_action_just_pressed("draw_region"):
        dragStartMousePos = get_global_mouse_position()
        isDrawingRegion = true
        
    if isDrawingRegion and Input.is_action_just_released("draw_region"):
        isDrawingRegion = false
        create_region(Rect2(dragStartMousePos, dragSizeVector))
        queue_redraw()
        
    if isDrawingRegion:
        dragSizeVector = get_global_mouse_position() - dragStartMousePos
        queue_redraw()
        
func create_region(rect: Rect2):
    var region = region_scene.instantiate()
    region.setup(rect)
    region.popup_opened.connect(_on_region_popup_opened)
    region.popup_closed.connect(_on_region_popup_closed)
    undo_redo.create_action("Create Region")
    undo_redo.add_do_method(add_child.bind(region))
    undo_redo.add_undo_method(remove_child.bind(region))
    undo_redo.commit_action()
    
func draw_entrance(delta):
    pass
        
func create_entrance(delta):
    pass
    


func _on_region_popup_opened() -> void:
    region_popup_opened.emit()


func _on_region_popup_closed() -> void:
    region_popup_closed.emit()
    
