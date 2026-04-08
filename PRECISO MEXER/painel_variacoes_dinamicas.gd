
extends Panel

@onready var vbox_esquerdo: VBoxContainer = $Margem/ScrollContainer/HBoxContainer/VBoxContainerEsquerdo
@onready var vbox_direito: VBoxContainer = $Margem/ScrollContainer/HBoxContainer/VBoxContainerDireito

var tipo_selecionado: String = "Quadro"


func _on_tipo_foi_selecionado(tipo: String) -> void:
	print("Ativou a função _on_tipo_foi_selecionado!")
	if CatalogoPecas.variacoes_por_tipo.has(tipo):
		tipo_selecionado = tipo
		atualizar_painel()
	else:
		print("ERRO! Tipo ", tipo, " inexistente em CatalogoPecas.variacoes_por_tipo")



func atualizar_painel():
	# ideia: fazer o painel ser montado dinamicamente usando todas as
	# variações de peça
	
	# atualmente só tenho as imagens renderizadas dos quadros. Falta o das
	# outras peças
	
	
	var variacoes = CatalogoPecas.variacoes_por_tipo[tipo_selecionado]
	print("Variações: ", variacoes)
