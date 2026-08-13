extends Node2D

signal region_popup_opened
signal region_popup_closed

var region_scene = preload("res://region.tscn")
var isDrawingRegion = false
var dragStartMousePos: Vector2
var dragSizeVector: Vector2
var isMerging = false
var mergingRegion = null

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
        if not Input.is_key_pressed(KEY_SHIFT):
            return
        dragStartMousePos = get_global_mouse_position()
        isDrawingRegion = true
        isMerging = false
        
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
    region.delete_region.connect(_on_delete_region)
    region.merge_start.connect(_on_merge_start)
    region.clicked_region.connect(_on_region_clicked)
    region.name_change_request.connect(_on_region_name_change_requested)
    region.color_change_request.connect(_on_region_color_change_requested)
    undo_redo.create_action("Create Region")
    undo_redo.add_do_method(add_child.bind(region))
    undo_redo.add_undo_method(remove_child.bind(region))
    undo_redo.commit_action()
    
func draw_entrance(delta):
    pass
        
func create_entrance(delta):
    pass
func do_region_merge(region, new_parent_region):
    region.do_merge(new_parent_region)

func restore_regions(snapshot):
    for region in snapshot:
        var state = snapshot[region]

        region.is_merge_controller = state.is_merge_controller
        region.merge_controller = state.merge_controller
        region.region_references = state.region_references.duplicate()
        region.region_name = state.region_name
        region.region_color = state.region_color
        region.queue_redraw()
        
func undo_region_merge(region_state1, region_state2):
    restore_regions(region_state1)
    restore_regions(region_state2)


func _on_region_popup_opened() -> void:
    region_popup_opened.emit()


func _on_region_popup_closed() -> void:
    region_popup_closed.emit()

func _on_delete_region(region) -> void:
    undo_redo.create_action("Delete Region")
    undo_redo.add_do_method(delete_region_and_reference.bind(region))
    undo_redo.add_undo_method(redo_region_and_reference.bind(region))
    undo_redo.commit_action()

func delete_region_and_reference(region):
    if region.merge_controller != null:
        region.merge_controller.remove_region_reference(region) 
    remove_child.bind(region)
    
func redo_region_and_reference(region):
    if region.merge_controller != null:
        region.merge_controller.add_region_reference(region) 
    add_child.bind(region)

func _on_merge_start(region):
    isMerging = true
    mergingRegion = region
    
    
func _on_region_clicked(region):
    if isMerging:
        if region.is_merge_valid(mergingRegion):
            undo_redo.create_action("Merge Region")
            undo_redo.add_do_method(do_region_merge.bind(region, mergingRegion))
            undo_redo.add_undo_method(undo_region_merge.bind(region.snapshot_regions(), mergingRegion.snapshot_regions()))
            undo_redo.commit_action()
        isMerging = false
        
func _on_region_name_change_requested(region, new_name):
    var old_name = region.region_name

    undo_redo.create_action("Change Region Name")

    undo_redo.add_do_method(region.set_region_name.bind(new_name))
    undo_redo.add_undo_method(region.set_region_name.bind(old_name))

    undo_redo.commit_action()
func _on_region_color_change_requested(region, new_color, old_color):

    undo_redo.create_action("Change Region Color")

    undo_redo.add_do_method(region.set_region_color.bind(new_color))
    undo_redo.add_undo_method(region.set_region_color.bind(old_color))

    undo_redo.commit_action()
        
        
