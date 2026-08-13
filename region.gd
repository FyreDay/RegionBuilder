extends Node2D

signal popup_opened
signal popup_closed

@onready var edit_menu: PopupPanel = $EditMenu
@onready var name_edit: LineEdit = $EditMenu/VBoxContainer/NameEdit
@onready var color_changer: ColorPickerButton = $EditMenu/VBoxContainer/ColorChanger

var region_color := Color.WHITE
var node_rect := Rect2(Vector2.ZERO,Vector2(100,100))
var region_name = ""
const alpha = .3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func setup(rect: Rect2):
    node_rect = rect
    region_color = Color.from_hsv(randf(), 1.0, 1.0,alpha)
    show_behind_parent = true

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

func open_edit_menu():
    popup_opened.emit()
    name_edit.text = region_name
    color_changer.color = Color(region_color, 1.0)
    
    edit_menu.position = get_viewport().get_mouse_position()
    edit_menu.reset_size()
    edit_menu.popup()


func _on_edit_menu_popup_hide() -> void:
    popup_closed.emit()


func _on_color_changer_color_changed(color: Color) -> void:
    region_color = Color(color, alpha)
    queue_redraw()


func _on_name_edit_text_changed(new_text: String) -> void:
    region_name = new_text
    queue_redraw()


func _on_delete_button_pressed() -> void:
    queue_free()
