
@tool
extends Button

@export var resource_tipo: TipoPecaData

static var id_tipo_selecionado: String = "Quadro"

func _ready() -> void:
	if resource_tipo and resource_tipo.silhueta_texture:
		var novo_style = StyleBoxTexture.new()
		novo_style.texture = resource_tipo.silhueta_texture
		
		add_theme_stylebox_override("normal", novo_style)
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_pressed() -> void:
	id_tipo_selecionado = resource_tipo.id
	print("BOTÃO PRESSIONADO. TIPO_SELECIONADO: ", id_tipo_selecionado)
	
	var nodo_oficina = get_tree().current_scene
	if nodo_oficina and nodo_oficina.has_signal("tipo_foi_selecionado"):
		nodo_oficina.tipo_foi_selecionado.emit(id_tipo_selecionado)
