extends Node2D

@onready var map_sprite: Sprite2D = $map_sprite
@onready var camera: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func set_map(path: String) -> void:
    var image := Image.load_from_file(path)

    if image == null:
        print("Failed to load image: ", path)
        return

    var texture := ImageTexture.create_from_image(image)
    map_sprite.texture = texture


    
