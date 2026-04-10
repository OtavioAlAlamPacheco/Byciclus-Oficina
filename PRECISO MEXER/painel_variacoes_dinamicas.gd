
extends Panel

@onready var vbox_esquerdo: VBoxContainer = $Margem/ScrollContainer/HBoxContainer/VBoxContainerEsquerdo
@onready var vbox_direito: VBoxContainer = $Margem/ScrollContainer/HBoxContainer/VBoxContainerDireito
@onready var monta_bike: Node3D = get_tree().get_first_node_in_group("bike")

const PAINEL_SELECAO_VARIACAO: PackedScene = preload("uid://cqn781jst63vw")

var id_tipo_selecionado: String


func _on_tipo_foi_selecionado(id: String) -> void:
	print("Ativou a função _on_tipo_foi_selecionado!")
	if CatalogoPecas.variacoes_por_tipo.has(id):
		id_tipo_selecionado = id
		limpar_paineis()
		atualizar_paineis()
	else:
		print("ERRO! Tipo ", id, " inexistente em CatalogoPecas.variacoes_por_tipo. \n",
			   "Variacoes_por_tipo: ", CatalogoPecas.variacoes_por_tipo)


func limpar_paineis():
	for painel in vbox_esquerdo.get_children():
		painel.queue_free()
	
	for painel in vbox_direito.get_children():
		painel.queue_free()


func atualizar_paineis():
	var variacoes: Array = CatalogoPecas.variacoes_por_tipo[id_tipo_selecionado]
	
	var num_variacoes = variacoes.size()
	print("NUM_VARIACOES: ", num_variacoes)
	
	var var_esquerda: int = ceil(num_variacoes / 2.0)
	print("Var_esquerda: ", var_esquerda)
	
	for i in range(variacoes.size()):
		var novo_painel = PAINEL_SELECAO_VARIACAO.instantiate()
		var botao = novo_painel.get_child(0)
		
		botao.resource_variacao = CatalogoPecas.resource_das_variacoes[variacoes[i]]
		
		# Distribui entre as colunas
		if i < var_esquerda:
			vbox_esquerdo.add_child(novo_painel)
		else:
			vbox_direito.add_child(novo_painel)
	
	
	print("\n\n\n\n\nAQUI2")
	
	if monta_bike.instancias_ativas.has(id_tipo_selecionado):
		print("\nEncontrou o tipo selecionado em instancias_ativas!")
		print("Instancia_da_peca: ", monta_bike.instancias_ativas[id_tipo_selecionado])
	
	if monta_bike:
		print("\n\nInstancias ativas: ", monta_bike.instancias_ativas)
