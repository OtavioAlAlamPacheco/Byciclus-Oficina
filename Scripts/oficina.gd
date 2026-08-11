
extends Node3D

signal tipo_foi_selecionado(id: String)
signal variacao_foi_selecionada(id: String)

@onready var bike: Node3D = $Bike
@onready var menu_dinamico: Panel = %MenuSelecaoVariacaoPeca
@onready var botao_modo_visualizacao: Button = %ButtonVisualizarBike

var modo_visualizacao: String = "Visualizar bicicleta"


func _ready():
	print("-------------------- READY DO OFICINA --------------------")
	
	if menu_dinamico:
		self.tipo_foi_selecionado.connect(menu_dinamico._on_tipo_foi_selecionado)
		self.tipo_foi_selecionado.connect(botao_modo_visualizacao._on_tipo_foi_selecionado)
		self.variacao_foi_selecionada.connect(menu_dinamico._on_variacao_foi_selecionada)
	
	bike.seleciona_todas_pecas()


func solicitar_selecao_tipo(id: String) -> void:
	tipo_foi_selecionado.emit(id)


func solicitar_selecao_variacao(id: String) -> void:
	variacao_foi_selecionada.emit(id)


func alterar_modo_visualizacao(novo_modo: String) -> void:
	modo_visualizacao = novo_modo
	get_tree().call_group("botao_modo_visualizacao", "_atualizar_painel", novo_modo)
