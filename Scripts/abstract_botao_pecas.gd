
@tool
extends Button
class_name botao_peca

@export var imagem_fundo: CompressedTexture2D

func _ready() -> void:
	var novo_style = StyleBoxTexture.new()
	novo_style.texture = imagem_fundo
	
	add_theme_stylebox_override("normal", novo_style)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
