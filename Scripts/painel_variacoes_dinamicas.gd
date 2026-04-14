
extends Panel

@onready var vbox_esquerdo: VBoxContainer = $Margem/ScrollContainer/HBoxContainer/VBoxContainerEsquerdo
@onready var vbox_direito: VBoxContainer = $Margem/ScrollContainer/HBoxContainer/VBoxContainerDireito
@onready var bike: Node3D = get_tree().get_first_node_in_group("bike")

const PAINEL_SELECAO_VARIACAO: PackedScene = preload("uid://cqn781jst63vw")

var id_tipo_selecionado: String
var id_variacao_selecionada: String


func _ready() -> void:
	await get_tree().process_frame
	print("-------------------- READY DO PAINEL_VARIACOES_DINAMICAS (com await) --------------------")
	_on_tipo_foi_selecionado("Quadro")


func _on_tipo_foi_selecionado(id: String) -> void:
	print("Ativou a função _on_tipo_foi_selecionado!")
	if CatalogoPecas.variacoes_por_tipo.has(id):
		id_tipo_selecionado = id
		limpar_paineis()
		atualizar_paineis()
	else:
		print("ERRO! Tipo ", id, " inexistente em CatalogoPecas.variacoes_por_tipo. \n",
			  "Variacoes_por_tipo: ", CatalogoPecas.variacoes_por_tipo)

func _on_variacao_foi_selecionada(id: String):
	print("Ativou o _on_variacao_foi_selecionada dentro de ", self)
	limpar_paineis()
	atualizar_paineis()


func limpar_paineis():
	for painel in vbox_esquerdo.get_children():
		painel.queue_free()
	
	for painel in vbox_direito.get_children():
		painel.queue_free()


func atualizar_paineis():
	print("\nCatalogoPecas.variacoes_por_tipo: ", CatalogoPecas.variacoes_por_tipo)
	print("\nid_tipo_selecionado: ", id_tipo_selecionado)
	var variacoes: Array = CatalogoPecas.variacoes_por_tipo[id_tipo_selecionado]
	
	var num_variacoes = variacoes.size()
	print("NUM_VARIACOES: ", num_variacoes)
	
	var var_esquerda: int = ceil(num_variacoes / 2.0)
	print("Var_esquerda: ", var_esquerda)
	
	var novo_painel
	
	for data in bike.pecas_instanciadas:
		if id_tipo_selecionado == data.resource_tipo.id:
			print("\nEncontrou o tipo selecionado em pecas_instanciadas!")
			print("Instância: ", data.instancia)
			
			id_variacao_selecionada = data.resource_variacao.id
	
	for i in range(variacoes.size()):
		novo_painel = PAINEL_SELECAO_VARIACAO.instantiate()
		var botao = novo_painel.get_child(0)
		
		var resource_variacao = CatalogoPecas.resource_das_variacoes[variacoes[i]]
		botao.resource_variacao = resource_variacao
		
		if resource_variacao.id == id_variacao_selecionada:
			print("Essa é a peça selecionada atualmente: ", resource_variacao.id, ", ", id_variacao_selecionada)
			var style_box = novo_painel.get_theme_stylebox("panel").duplicate()
			style_box.bg_color = Color("d8dab8")
			novo_painel.add_theme_stylebox_override("panel", style_box)
		
		if i < var_esquerda:
			vbox_esquerdo.add_child(novo_painel)
		else:
			vbox_direito.add_child(novo_painel)
