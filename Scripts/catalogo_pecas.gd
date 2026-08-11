
extends Node

var banco_de_dados: BancoDePecasData = preload("res://Resources/banco_de_pecas.tres")
const BancoDePecasData = preload("uid://cvsj3i3wqb7ui")

var variacoes_por_tipo: Dictionary = {
	#	"id_tipo": ["resource_variacao_1", "resource_variacao_2", ...]
}

var resource_das_variacoes: Dictionary = {
	# "id_variacao": resource_variacao
}

var resource_dos_tipos: Dictionary = {
	# "id_tipo": resource_tipo
}

func _ready() -> void:
	print("-------------------- READY DO CATALOGO_PECAS --------------------")
	_carregar_pecas_do_banco()

func _carregar_pecas_do_banco() -> void:
	if not banco_de_dados:
		print("ERRO: Banco de peças não configurado no Autoload CatalogoPecas!")
		return
	
	for tipo in banco_de_dados.tipos_disponiveis:
		if tipo:
			var id_t = tipo.id
			resource_dos_tipos[id_t] = tipo
			variacoes_por_tipo[id_t] = []
			
	for variacao in banco_de_dados.variacoes_disponiveis:
		if variacao:
			resource_das_variacoes[variacao.id] = variacao
			
			if variacao.tipo and variacao.tipo.id in variacoes_por_tipo:
				variacoes_por_tipo[variacao.tipo.id].append(variacao.id)
