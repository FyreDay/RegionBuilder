extends Node2D

signal popup_opened
signal popup_closed
signal delete_region
signal merge_start
signal clicked_region
signal name_change_request
signal color_change_request

@onready var edit_menu: PopupPanel = $EditMenu
@onready var name_edit: LineEdit = $EditMenu/VBoxContainer/NameEdit
@onready var color_changer: ColorPickerButton = $EditMenu/VBoxContainer/ColorChanger

var region_color := Color.WHITE
var old_region_color
var node_rect := Rect2(Vector2.ZERO,Vector2(100,100))
var region_name = ""
const alpha = .3

var merge_controller
var region_references
var is_merge_controller
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func setup(rect: Rect2):
    node_rect = rect.abs()
    region_color = Color.from_hsv(randf(), 1.0, 1.0,alpha)
    show_behind_parent = true
    merge_controller = null
    region_references = []
    is_merge_controller = true

func _draw() -> void:
    var font := ThemeDB.fallback_font
    var font_size := 16
    var text_width := font.get_string_size(region_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
    
    var x := node_rect.position.x + (node_rect.size.x - text_width) / 2.0
    var y := node_rect.position.y + font_size
    draw_rect(node_rect, region_color)
    draw_string(font,Vector2(x, y),region_name,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("open_object_menu"):
        if Input.is_key_pressed(KEY_SHIFT):
            return
        var mouse_pos := get_global_mouse_position()

        if node_rect.has_point(to_local(mouse_pos)):
            open_edit_menu()
    if event.is_action_pressed("click"):
        var mouse_pos := get_global_mouse_position()

        if node_rect.has_point(to_local(mouse_pos)):
            clicked_region.emit(self)

func open_edit_menu():
    if not is_merge_controller:
        merge_controller.open_edit_menu()
        return
    popup_opened.emit()
    name_edit.text = region_name
    color_changer.color = Color(region_color, 1.0)
    
    edit_menu.position = get_viewport().get_mouse_position()
    edit_menu.reset_size()
    edit_menu.popup()

func is_merge_valid(new_merge_controller):
    if self == new_merge_controller:
        return false
    if merge_controller != null and new_merge_controller.merge_controller != null:
        if merge_controller == new_merge_controller.merge_controller:
            return false
    if merge_controller == new_merge_controller:
        return false
    if is_merge_controller and new_merge_controller.merge_controller == self:
        return false
    return true
        
        
func get_merge_state():
    return {
        "is_merge_controller": is_merge_controller,
        "merge_controller": merge_controller,
        "region_references": region_references.duplicate(),
        "region_name": region_name,
        "region_color": region_color,
    }
    
func snapshot_regions():
    var snapshot = {}

    for region in region_references:
        snapshot[region] = region.get_merge_state()
    snapshot[self] = self.get_merge_state()
    if merge_controller != null:
        snapshot[merge_controller] = merge_controller.get_merge_state()
    return snapshot
    
func do_merge(new_merge_controller):
    if not is_merge_valid(new_merge_controller):
        return
    if is_merge_controller and region_references.size() > 0:
        var new_parent_region = region_references[0]
        new_parent_region.merge_controller = null
        new_parent_region.is_merge_controller = true
        new_parent_region.region_references = region_references.slice(1)
        for new_child in new_parent_region.region_references:
            new_child.merge_controller = new_parent_region
        region_references = []
    is_merge_controller = false
    if merge_controller != null:
        merge_controller.remove_region_reference(self)
    merge_controller = new_merge_controller
    region_name = merge_controller.region_name
    region_color = merge_controller.region_color
    merge_controller.add_region_reference(self)
    
    queue_redraw()
    
    
func add_region_reference(region):
    region_references.append(region)
    
func remove_region_reference(region):
    region_references.erase(region)
    

func _on_edit_menu_popup_hide() -> void:
    popup_closed.emit()


func _on_color_changer_color_changed(color: Color) -> void:
    region_color = Color(color, alpha)
    set_region_color(region_color)



func _on_name_edit_text_changed(new_text: String) -> void:
    name_change_request.emit(self, new_text)
    
func set_region_name(new_name: String) -> void:
    for region in region_references:
        region.set_region_name(new_name)

    region_name = new_name
    queue_redraw()
    
func set_region_color(new_color: Color) -> void:
    if is_merge_controller:
        for region in region_references:
            region.set_region_color(new_color)

    region_color = Color(new_color, alpha)
    queue_redraw()


func _on_delete_button_pressed() -> void:
    edit_menu.hide()
    delete_region.emit(self)
    
func _on_merge_button_pressed() -> void:
    if is_merge_controller:
        merge_start.emit(self)
    else:
        merge_start.emit(merge_controller)
        


func _on_color_changer_popup_closed() -> void:
    color_change_request.emit(self, region_color, old_region_color)


func _on_color_changer_picker_created() -> void:
    old_region_color = region_color
