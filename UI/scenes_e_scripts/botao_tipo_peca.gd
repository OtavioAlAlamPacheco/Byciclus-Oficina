
@tool
extends Button

@export var resource_tipo: TipoPecaData


func _ready() -> void:
	if resource_tipo and resource_tipo.silhueta_texture:
		icon = resource_tipo.silhueta_texture
		expand_icon = true
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _on_pressed() -> void:
	var id_tipo_selecionado = resource_tipo.id
	var nodo_oficina = get_tree().get_first_node_in_group("oficina")
	if nodo_oficina and nodo_oficina.has_method("solicitar_selecao_tipo"):
		nodo_oficina.solicitar_selecao_tipo(id_tipo_selecionado)
