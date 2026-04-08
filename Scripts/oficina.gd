

extends Node3D

signal tipo_foi_selecionado(tipo: String)

@onready var monta_bike: Node3D = $MontaBike

@onready var menu_dinamico: Panel = $CanvasLayer/InterfaceMenuOficina/MargemPrincipal/PaineisSuperiores/MenuSelecaoVariacaoPeca

var pecas_selecionadas: Array = []

func _ready():
	CatalogoPecas.catalogar_variacoes()
	
	if menu_dinamico:
		self.tipo_foi_selecionado.connect(menu_dinamico._on_tipo_foi_selecionado)
	
	seleciona_todas_pecas()


func seleciona_todas_pecas():
	pecas_selecionadas.clear()
	for id in CatalogoPecas.resource_das_variacoes:
		pecas_selecionadas.append(id)
	
	if monta_bike:
		monta_bike.seleciona_pecas(pecas_selecionadas)
	else:
		print("ERRO: Monta_bike em oficina.gd é ", monta_bike)
