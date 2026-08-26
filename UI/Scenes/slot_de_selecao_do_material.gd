
extends VBoxContainer

@export var cena_botao_material: PackedScene
@onready var label_titulo: Label = $Label
@onready var container_botoes: HBoxContainer = $ScrollContainer/Slot


func configurar_slot(slot_data: SlotMaterialData, variacao: VariacaoPecaData, slot_index: int, popup_ref: CanvasLayer = null) -> void:
	label_titulo.text = "Selecione o material para " + slot_data.nome_do_slot
	
	for filho in container_botoes.get_children():
		filho.queue_free()
		
	for material in slot_data.materiais_disponiveis:
		var novo_botao = cena_botao_material.instantiate()
		container_botoes.add_child(novo_botao)
		novo_botao.configurar_botao(material, variacao, slot_index, popup_ref)
		
		if not novo_botao.pressed.is_connected(_on_botao_pressionado):
			novo_botao.pressed.connect(_on_botao_pressionado.bind(novo_botao))


func _on_botao_pressionado(botao_clicado: Button) -> void:
	for botao in container_botoes.get_children():
		if botao.has_method("atualizar_tema"):
			botao.atualizar_tema(botao == botao_clicado)
