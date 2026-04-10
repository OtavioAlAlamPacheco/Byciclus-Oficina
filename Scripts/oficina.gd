

extends Node3D

signal tipo_foi_selecionado(id: String)
signal variacao_foi_selecionada(id: String)

@onready var monta_bike: Node3D = $MontaBike

@onready var menu_dinamico: Panel = $CanvasLayer/InterfaceMenuOficina/MargemPrincipal/PaineisSuperiores/MenuSelecaoVariacaoPeca


func _ready():
	CatalogoPecas.catalogar_variacoes()
	CatalogoPecas.catalogar_tipos()
	
	if menu_dinamico:
		self.tipo_foi_selecionado.connect(menu_dinamico._on_tipo_foi_selecionado)
	
	monta_bike.seleciona_todas_pecas()
