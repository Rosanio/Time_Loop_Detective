extends ColorRect

@onready var viewport: Viewport = get_tree().get_root().get_node("/root/Main/VisionViewport")
@onready var shader_mat: ShaderMaterial = material as ShaderMaterial

func _ready() -> void:
	var tex = viewport.get_texture()
	shader_mat.set_shader_parameter("vision_mask", tex)
