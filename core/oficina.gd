
extends Control

signal tipo_foi_selecionado(id: String)
signal variacao_foi_selecionada(id: String)

@onready var popup_materiais: CanvasLayer = %PopupMateriais
@onready var bike: Node3D = %Bike
@onready var pivo_peca: Node3D = %PivoPeca
@onready var menu_variacao_peca: Panel = %MenuSelecaoVariacaoPeca
@onready var botao_modo_visualizacao: Button = %ButtonVisualizarBike

var modo_visualizacao: String = "Visualizar bicicleta"
var id_variacao_backup: String = ""
var dados_backup_peca: Dictionary = {}


func _ready():
	if menu_variacao_peca:
		self.tipo_foi_selecionado.connect(menu_variacao_peca._on_tipo_foi_selecionado)
		self.tipo_foi_selecionado.connect(botao_modo_visualizacao._on_tipo_foi_selecionado)
		self.variacao_foi_selecionada.connect(menu_variacao_peca._on_variacao_foi_selecionada)
		
		if is_instance_valid(popup_materiais):
			popup_materiais.popup_fechado.connect(menu_variacao_peca._on_popup_fechado)
	
	if is_instance_valid(bike):
		self.variacao_foi_selecionada.connect(bike._on_oficina_variacao_foi_selecionada)
		
	if is_instance_valid(pivo_peca):
		self.variacao_foi_selecionada.connect(pivo_peca._on_oficina_variacao_foi_selecionada)
		pivo_peca.hide()
	
	bike.seleciona_todas_pecas()


func solicitar_selecao_tipo(id: String) -> void:
	tipo_foi_selecionado.emit(id)


func solicitar_selecao_variacao(id: String) -> void:
	var resource_variacao = CatalogoPecas.resource_das_variacoes[id]
	
	if is_instance_valid(bike) and bike.has_method("obter_backup_peca"):
		dados_backup_peca = bike.obter_backup_peca(resource_variacao.tipo.id)
	
	variacao_foi_selecionada.emit(id)
	
	if is_instance_valid(popup_materiais):
		popup_materiais.abrir_popup(resource_variacao.tipo, resource_variacao)


func reverter_variacao() -> void:
	if not dados_backup_peca.is_empty():
		variacao_foi_selecionada.emit(dados_backup_peca["id_variacao"])
		
		if is_instance_valid(bike) and bike.has_method("restaurar_materiais_do_backup"):
			bike.restaurar_materiais_do_backup(dados_backup_peca)
			
		dados_backup_peca.clear()


func alterar_modo_visualizacao(novo_modo: String) -> void:
	modo_visualizacao = novo_modo
	get_tree().call_group("botao_modo_visualizacao", "_atualizar_painel", novo_modo)


func aplicar_material_na_bike(id_variacao: String, material: Material, slot_index: int) -> void:
	if is_instance_valid(bike) and bike.has_method("aplicar_material"):
		bike.aplicar_material(id_variacao, material, slot_index)


func confirmar_alteracoes() -> void:
	if is_instance_valid(bike) and bike.has_method("obter_dados_da_bike"):
		var receita = bike.obter_dados_da_bike()
		
		var id_gerado = "bike_" + str(Time.get_unix_time_from_system())
		
		GerenciadorSaveBikes.salvar_bike(id_gerado, receita)


# essa função é só pra teste/debug
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("teste") and OS.has_feature("editor"):
		var todas_as_bikes = GerenciadorSaveBikes.carregar_todas_as_bikes()
		
		if todas_as_bikes.is_empty():
			push_error("Nenhuma bike encontrada no arquivo de save.")
			return
			
		var ids_salvos = todas_as_bikes.keys()
		var id_ultima_bike = ids_salvos[-1]                              
		
		if is_instance_valid(bike) and bike.has_method("carregar_dados_da_bike"):
			bike.carregar_dados_da_bike(todas_as_bikes[id_ultima_bike])
