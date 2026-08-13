extends Node2D

@onready var map = $Map
@onready var ui = $UI
@onready var node_manager = $NodeManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ui.map_selected.connect(map.set_map)
    node_manager.region_popup_opened.connect(map.camera.disable_input)
    node_manager.region_popup_closed.connect(map.camera.enable_input)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
