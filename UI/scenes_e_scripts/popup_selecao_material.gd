
extends CanvasLayer

signal popup_fechado

@export var cena_slot_material: PackedScene

@onready var container_slots: VBoxContainer = $Panel/Margem/ScrollContainer/VBoxContainer
@onready var painel_principal: Panel = $Panel

var variacao_atual: VariacaoPecaData
var tipo_atual: TipoPecaData

var peca_confirmada: bool = false
var slots_preenchidos: Dictionary = {}

var resolucao_base: Vector2 = Vector2(1152.0, 648.0)


func _ready() -> void:
	get_tree().root.size_changed.connect(_atualizar_escala_do_painel)
	call_deferred("_atualizar_escala_do_painel")
	
	hide()


func abrir_popup(tipo: TipoPecaData, variacao: VariacaoPecaData) -> void:
	tipo_atual = tipo
	variacao_atual = variacao
	peca_confirmada = false
	
	slots_preenchidos.clear()
	_limpar_slots()
	_gerar_slots()
	_atualizar_escala_do_painel()
	aplicar_tween_popup()
	show()


func aplicar_tween_popup() -> void:
	var escala_alvo = painel_principal.scale
	var posicao_alvo = painel_principal.position
	
	painel_principal.scale = Vector2(0.05, 0.05)
	painel_principal.modulate = Color(1, 1, 1, 0)	
	painel_principal.position = posicao_alvo + Vector2(0, 50)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(painel_principal, "scale", escala_alvo, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(painel_principal, "modulate", Color(1, 1, 1, 1), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(painel_principal, "position", posicao_alvo, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func fechar_popup() -> void:
	if not peca_confirmada and not _todos_slots_preenchidos():
		var oficina = get_tree().get_first_node_in_group("oficina")
		if oficina and oficina.has_method("reverter_variacao"):
			oficina.reverter_variacao()
			
	_aplicar_tween_fechamento()


func _aplicar_tween_fechamento() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	var posicao_alvo = painel_principal.position + Vector2(0, 50)
	
	tween.tween_property(painel_principal, "scale", Vector2(0.05, 0.05), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(painel_principal, "modulate", Color(1, 1, 1, 0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(painel_principal, "position", posicao_alvo, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_finalizar_fechamento)


func _finalizar_fechamento() -> void:
	popup_fechado.emit()
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


func _atualizar_escala_do_painel() -> void:
	if not is_instance_valid(painel_principal):
		return
		
	var tamanho_tela = get_viewport().get_visible_rect().size
	var fator_escala = min(tamanho_tela.x / resolucao_base.x, tamanho_tela.y / resolucao_base.y)
	
	painel_principal.pivot_offset = painel_principal.size / 2.0
	painel_principal.scale = Vector2(fator_escala, fator_escala)
	
	painel_principal.position = (tamanho_tela - painel_principal.size) / 2.0


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
