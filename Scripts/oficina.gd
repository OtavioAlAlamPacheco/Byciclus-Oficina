

extends Node3D

signal tipo_foi_selecionado(id: String)
signal variacao_foi_selecionada(id: String)

@onready var bike: Node3D = $Bike
@onready var menu_dinamico: Panel = $CanvasLayer/InterfaceMenuOficina/MargemPrincipal/PaineisSuperiores/MenuSelecaoVariacaoPeca
@onready var script_variacao_peca: Script = load("res://Scripts/botao_variacao_peca.gd")


func _ready():
	print("-------------------- READY DO OFICINA --------------------")
	
	CatalogoPecas.catalogar_variacoes()
	CatalogoPecas.catalogar_tipos()
	
	if menu_dinamico:
		self.tipo_foi_selecionado.connect(menu_dinamico._on_tipo_foi_selecionado)
		self.variacao_foi_selecionada.connect(menu_dinamico._on_variacao_foi_selecionada)
	
	
	
	bike.seleciona_todas_pecas()
