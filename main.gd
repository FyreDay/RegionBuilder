extends Node2D

@onready var map = $Map
@onready var ui = $UI
@onready var node_manager = $NodeManager

var pending_json: String
var pending_meta_json: String
var pending_image: Image
var pending_image_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ui.map_selected.connect(map.set_map_path)
    ui.save_data.connect(_on_save_data)
    ui.save_path.connect(_on_save_path)
    ui.load_data.connect(_on_load_data)
    node_manager.popup_opened.connect(map.camera.disable_input)
    node_manager.popup_closed.connect(map.camera.enable_input)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_load_data(path):
    var zip := ZIPReader.new()
    var err := zip.open(path)
    if err != OK:
        push_error("Failed to open ZIP: " + path)
        zip.close()
        return
    if not zip.file_exists("metadata.json"):
        push_error("Invalid project: metadata.json is missing")
        zip.close()
        return
    if not zip.file_exists("nodes.json"):
        push_error("Invalid project: nodes.json is missing")
        zip.close()
        return
        
    var meta_bytes := zip.read_file("metadata.json")
    var meta_text := meta_bytes.get_string_from_utf8()
    
    var meta = JSON.parse_string(meta_text)
    
    if not meta.has("version"):
        push_error("Invalid project: missing version")
        zip.close()
        return

    if meta.version != "0.0.1":
        push_error("Unsupported project version: " + str(meta.version))
        zip.close()
        return
        
    if not meta.has("image_name"):
        push_error("Invalid project: missing image name")
        zip.close()
        return
        
    var image := Image.new()
    
    if meta.image_name != "":
        if not zip.file_exists(meta.image_name):
            push_error("Invalid project: " + meta.image_name + " is missing")
            zip.close()
            return
        var image_bytes := zip.read_file(meta.image_name)
        err = image.load_png_from_buffer(image_bytes)
        if err != OK:
            push_error("Failed to load image")
            zip.close()
            return

    print("Metadata valid")
    
    var nodes_bytes := zip.read_file("nodes.json")
    var nodes_text := nodes_bytes.get_string_from_utf8()

    var nodes_data = JSON.parse_string(nodes_text)

    if nodes_data == null or not nodes_data is Dictionary:
        push_error("Invalid project: nodes.json is not valid JSON")
        zip.close()
        return
    if meta.image_name != "":
        map.set_map(image, meta.image_name)
    node_manager.load_data(nodes_data)
    
    zip.close()

func _on_save_data():
    print("save data")
    pending_json = JSON.stringify(node_manager.save_data())
    pending_image = map.image
    pending_meta_json = JSON.stringify({
        "version": "0.0.1",
        "image_name": map.image_name
    })
    pending_image_name = map.image_name
    print("open data prompt")
    ui.save_file_dialog.current_file = "map.zip"
    ui.save_file_dialog.popup_centered()
    
func _on_save_path(path):
    if not path.to_lower().ends_with(".zip"):
        path += ".zip"

    var zip := ZIPPacker.new()
    var err := zip.open(path)
    if err != OK:
        push_error("Failed to create ZIP: " + str(err))
        return
    
    zip.start_file("nodes.json")
    zip.write_file(pending_json.to_utf8_buffer())
    zip.close_file()

    zip.start_file("metadata.json")
    zip.write_file(pending_meta_json.to_utf8_buffer())
    zip.close_file()

    if pending_image != null:
        var image_buffer := pending_image.save_png_to_buffer()

        zip.start_file(pending_image_name)
        zip.write_file(image_buffer)
        zip.close_file()

        zip.close()

    print("Saved to: ", path)
    
