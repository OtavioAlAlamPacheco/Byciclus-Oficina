
extends CanvasLayer

@export var cena_slot_material: PackedScene

@onready var container_slots: VBoxContainer = $Panel/Margem/ScrollContainer/VBoxContainer
@onready var painel_principal: Panel = $Panel

var variacao_atual: VariacaoPecaData
var tipo_atual: TipoPecaData

var peca_confirmada: bool = false
var slots_preenchidos: Dictionary = {}


func _ready() -> void:
	hide()


func abrir_popup(tipo: TipoPecaData, variacao: VariacaoPecaData) -> void:
	tipo_atual = tipo
	variacao_atual = variacao
	peca_confirmada = false
	slots_preenchidos.clear()
	_limpar_slots()
	_gerar_slots()
	show()


func fechar_popup() -> void:
	if not peca_confirmada and not _todos_slots_preenchidos():
		var oficina = get_tree().get_first_node_in_group("oficina")
		if oficina and oficina.has_method("reverter_variacao"):
			oficina.reverter_variacao()
			
	hide()


func registrar_preenchimento_de_slot(slot_index: int) -> void:
	slots_preenchidos[slot_index] = true


func _todos_slots_preenchidos() -> bool:
	if not tipo_atual or tipo_atual.slots_e_materiais.is_empty():
		return true
	return slots_preenchidos.size() >= tipo_atual.slots_e_materiais.size()


func _limpar_slots() -> void:
	for filho in container_slots.get_children():
		filho.queue_free()


func _gerar_slots() -> void:
	if not tipo_atual or tipo_atual.slots_e_materiais.is_empty():
		return
	
	for i in range(tipo_atual.slots_e_materiais.size()):
		var slot_data = tipo_atual.slots_e_materiais[i]
		var novo_slot = cena_slot_material.instantiate()
		container_slots.add_child(novo_slot)
		novo_slot.configurar_slot(slot_data, variacao_atual, i, self)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if visible:
			var clique_valido = false
			var areas_validas = get_tree().get_nodes_in_group("area_do_popup")
			
			for area in areas_validas:
				if area is Control and area.is_visible_in_tree():
					var rect_global = area.get_global_rect()
					var mouse_global = area.get_global_mouse_position()
					
					if rect_global.has_point(mouse_global):
						clique_valido = true
						break
			
			if not clique_valido:
				fechar_popup()


func _on_botao_fechar_pressed() -> void:
	fechar_popup()


func _on_botao_confirmar_pressed() -> void:
	peca_confirmada = true
	fechar_popup()
