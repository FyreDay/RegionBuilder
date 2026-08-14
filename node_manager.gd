extends Node2D

signal popup_opened
signal popup_closed
signal hovered_region_update

var region_scene = preload("res://region.tscn")
var entrance_scene = preload("res://entrance.tscn")
var isDrawingRegion = false
var isDrawingEntrance = false
var dragStartMousePos: Vector2
var dragSizeVector: Vector2
var isMerging = false
var mergingRegion = null
var hovered_region = null
var entrance_from_region = null

var regions = []
var entrances = null

var undo_redo := UndoRedo.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    draw_region(delta)
    draw_entrance(delta)
    update_hovered_region()
    
func update_hovered_region():
    var mouse_pos := get_global_mouse_position()
    var new_hovered_region = null

    for region in regions:
        if not is_instance_valid(region):
            continue

        if region.node_rect.has_point(region.to_local(mouse_pos)):
            new_hovered_region = region
            break

    if new_hovered_region != hovered_region:
        hovered_region = new_hovered_region
        print(hovered_region)
        var controller_region = null
        if new_hovered_region != null:
             controller_region = hovered_region if hovered_region.is_merge_controller else hovered_region.merge_controller
        hovered_region_update.emit(hovered_region,controller_region)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("redo"):
        undo_redo.redo()
        return
    if event.is_action_pressed("undo"):
        undo_redo.undo()
    

func _draw() -> void:
    if isDrawingRegion:
        draw_rect(Rect2(dragStartMousePos, dragSizeVector), Color(1,1,1,.5))
    if isDrawingEntrance:
        var duel_directonal = Input.is_key_pressed(KEY_CTRL)
        var arrow_length := 15.0
        var arrow_width := 8.0
        
        var start := dragStartMousePos
        var end := dragStartMousePos + dragSizeVector
        
        # Direction and perpendicular
        var direction := (end - start).normalized()
        var perpendicular := Vector2(-direction.y, direction.x)
        end = end - direction * arrow_length
        if duel_directonal:
            start = start + direction * arrow_length
        draw_line(start, end, Color.BLACK, 8, true)
        
        

        if duel_directonal:
            draw_colored_polygon(
                PackedVector2Array([
                    start + 2 * direction - direction * arrow_length, 
                    start + 2 * direction + perpendicular * arrow_width, 
                    start + 2 * direction - perpendicular * arrow_width
                ]),
                Color.BLACK
            )
        draw_colored_polygon(
            PackedVector2Array([
                end - 2 * direction + direction * arrow_length,
                end - 2 * direction + perpendicular * arrow_width, 
                end - 2 * direction - perpendicular * arrow_width
                ]),
            Color.BLACK
        )

        draw_line(start - direction * 2, end + direction * 2, Color.WHITE, 6, true)
        var inner_length := 12.0
        var inner_width := 6.0
        if duel_directonal:
            draw_colored_polygon(
                PackedVector2Array([
                    start + direction * 1 - direction * inner_length, 
                    start + direction * 1 + perpendicular * inner_width, 
                    start + direction * 1 - perpendicular * inner_width
                ]),
                Color.WHITE
            )

        draw_colored_polygon(
            PackedVector2Array([
                end - direction * 1 + direction * inner_length, 
                end - direction * 1 + perpendicular * inner_width, 
                end - direction * 1 - perpendicular * inner_width
                ]),
            Color.WHITE
        )
    

func draw_region(delta):
    if isDrawingEntrance:
        return
        
    if !isDrawingRegion and Input.is_action_just_pressed("draw_region"):
        if not Input.is_key_pressed(KEY_SHIFT):
            return
        dragStartMousePos = get_global_mouse_position()
        isDrawingRegion = true
        isMerging = false
        
    if isDrawingRegion and Input.is_action_just_released("draw_region"):
        isDrawingRegion = false
        if abs(dragSizeVector.x) < 20:
            dragSizeVector.x = 20 * sign(dragSizeVector.x)
        if abs(dragSizeVector.y) < 20:
            dragSizeVector.y = 20 * sign(dragSizeVector.y)
            
        create_region(Rect2(dragStartMousePos, dragSizeVector))
        queue_redraw()
        
    if isDrawingRegion:
        dragSizeVector = get_global_mouse_position() - dragStartMousePos
        queue_redraw()
        
func create_region(rect: Rect2):
    var region = region_scene.instantiate()
    region.setup(rect)
    region.popup_opened.connect(_on_popup_opened)
    region.popup_closed.connect(_on_popup_closed)
    region.delete_region.connect(_on_delete_region)
    region.merge_start.connect(_on_merge_start)
    region.clicked_region.connect(_on_region_clicked)
    region.name_change_request.connect(_on_region_name_change_requested)
    region.color_change_request.connect(_on_region_color_change_requested)
    #TODO: move to undo/redo
    regions.append(region)
    undo_redo.create_action("Create Region")
    undo_redo.add_do_method(add_child.bind(region))
    undo_redo.add_undo_method(remove_child.bind(region))
    undo_redo.commit_action()
    
func draw_entrance(delta):
    if isDrawingRegion:
        return
    if !isDrawingEntrance and Input.is_action_just_pressed("draw_entrance"):
        if not Input.is_key_pressed(KEY_SHIFT) or hovered_region == null:
            return
        dragStartMousePos = get_global_mouse_position()
        entrance_from_region = hovered_region
        isDrawingEntrance = true
        isMerging = false
        
    if isDrawingEntrance and Input.is_action_just_released("draw_entrance"):
        isDrawingEntrance = false
        if hovered_region == null or hovered_region == entrance_from_region:
            queue_redraw()
            return
        var duel_directonal = Input.is_key_pressed(KEY_CTRL)
        var start := dragStartMousePos
        var end := dragStartMousePos + dragSizeVector
        create_entrance(entrance_from_region, hovered_region, start, end, duel_directonal)
        queue_redraw()
        
    if isDrawingEntrance:
        dragSizeVector = get_global_mouse_position() - dragStartMousePos
        queue_redraw()
        
func create_entrance(from_region, to_region, from_pos, to_pos, dual_directional):
    var entrance = entrance_scene.instantiate()
    entrance.setup(from_region, to_region, from_pos, to_pos, dual_directional)
    entrance.popup_opened.connect(_on_popup_opened)
    entrance.popup_closed.connect(_on_popup_closed)
    entrance.delete_entrance.connect(_on_delete_entrance)
    entrance.rule_change_request.connect(_on_rule_change)
    entrance.endpoint_drag_ended.connect(on_endpoint_drag_end)
    hovered_region_update.connect(entrance._on_hovered_region)
    undo_redo.create_action("Create Entrance")
    undo_redo.add_do_method(add_child.bind(entrance))
    undo_redo.add_undo_method(remove_child.bind(entrance))
    undo_redo.commit_action()
    
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


func _on_popup_opened() -> void:
    popup_opened.emit()


func _on_popup_closed() -> void:
    popup_closed.emit()

func _on_delete_region(region) -> void:
    print("delete")
    undo_redo.create_action("Delete Region")
    undo_redo.add_do_method(delete_region_and_reference.bind(region))
    undo_redo.add_undo_method(redo_region_and_reference.bind(region))
    undo_redo.commit_action()

func delete_region_and_reference(region):
    if not region.is_merge_controller:
        region.merge_controller.remove_region_reference(region) 
    remove_child.call_deferred(region)
    
func redo_region_and_reference(region):
    if not region.is_merge_controller:
        region.merge_controller.add_region_reference(region) 
    add_child(region)

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

        
func _on_delete_entrance(entrance):
    
    undo_redo.create_action("Delete Entrance")
    undo_redo.add_do_method(remove_child.bind(entrance))
    undo_redo.add_undo_method(add_child.bind(entrance))
    undo_redo.commit_action()
    
func _on_rule_change(entrance, rule_text):
    undo_redo.create_action("Change Rule")
    undo_redo.add_do_method(entrance.set_rule_text.bind(rule_text))
    undo_redo.add_undo_method(entrance.set_rule_text.bind(entrance.rule_text))
    undo_redo.commit_action()
    
func on_endpoint_drag_end(entrance, endpoint, old_pos, new_pos):
    undo_redo.create_action("Move Endpoint")
    undo_redo.add_do_method(entrance.set_endpoint.bind(endpoint, new_pos))
    undo_redo.add_undo_method(entrance.set_endpoint.bind(endpoint, old_pos))
    undo_redo.commit_action()
