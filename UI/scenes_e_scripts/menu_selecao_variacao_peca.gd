
@tool
extends Panel

@onready var grid_variacoes: GridContainer = $Margem/ScrollContainer/GridVariacoes
@onready var bike: Node3D = get_tree().get_first_node_in_group("bike")
@onready var banco_de_pecas = preload("uid://cvsj3i3wqb7ui")

const BOTAO_VARIACAO_PECA = preload("uid://bp00ux5jxvbmn")
const THEME_BOTAO_NAO_SELECIONADO = preload("uid://btfmvlloabut6")
const THEME_BOTAO_SELECIONADO = preload("uid://drfnkf2566lvj")

# theme botao nao selecionado               uid://xtha0ihy5e14      # AQUI
# theme botao nao selecionado (oficina)     uid://btfmvlloabut6

# theme botao selecionado              uid://drfnkf2566lvj
# theme botao selecionado (oficina)    uid://cexiw2525vqhn

var id_tipo_selecionado: String
var id_variacao_selecionada: String

@export var preview_tipo: TipoPecaData:
	set(valor):
		preview_tipo = valor
		if Engine.is_editor_hint() and is_inside_tree() and valor:
			_on_tipo_foi_selecionado(valor.id)


func _ready() -> void:
	if Engine.is_editor_hint():
		if preview_tipo:
			_on_tipo_foi_selecionado(preview_tipo.id)
	else:
		call_deferred("_on_tipo_foi_selecionado", "Quadro")


func _on_tipo_foi_selecionado(id: String) -> void:
	id_tipo_selecionado = id
	
	if Engine.is_editor_hint():
		limpar_paineis()
		_atualizar_paineis_editor()
	else:
		if CatalogoPecas.variacoes_por_tipo.has(id):
			limpar_paineis()
			_atualizar_paineis()
		else:
			push_error("Tipo ", id, " inexistente")


func _on_variacao_foi_selecionada(_id: String):
	if Engine.is_editor_hint():
		return
	
	call_deferred("_atualizar_themes")


func _on_popup_fechado() -> void:
	if Engine.is_editor_hint():
		return
	
	call_deferred("_atualizar_themes")

func _atualizar_themes() -> void:
	if is_instance_valid(bike):
		id_variacao_selecionada = bike.obter_variacao_ativa_do_tipo(id_tipo_selecionado)
		
	for botao in grid_variacoes.get_children():
		if "resource_variacao" in botao and botao.resource_variacao:
			if botao.resource_variacao.id == id_variacao_selecionada:
				botao.theme = THEME_BOTAO_SELECIONADO
			else:
				botao.theme = THEME_BOTAO_NAO_SELECIONADO


func limpar_paineis():
	for painel in grid_variacoes.get_children():
		painel.queue_free()


func _atualizar_paineis():
	var variacoes: Array = CatalogoPecas.variacoes_por_tipo[id_tipo_selecionado]
	
	if is_instance_valid(bike):
		id_variacao_selecionada = bike.obter_variacao_ativa_do_tipo(id_tipo_selecionado)
	
	for i in range(variacoes.size()):
		var botao = BOTAO_VARIACAO_PECA.instantiate()
		
		var resource_variacao = CatalogoPecas.resource_das_variacoes[variacoes[i]]
		botao.resource_variacao = resource_variacao
		
		botao.icon = null
		
		if resource_variacao.id == id_variacao_selecionada:
			botao.theme = THEME_BOTAO_SELECIONADO
		else:
			botao.theme = THEME_BOTAO_NAO_SELECIONADO
		
		grid_variacoes.add_child(botao)


func _atualizar_paineis_editor() -> void:
	if not banco_de_pecas:
		push_error("Banco de peças não foi carregado corretamente.")
		return
	
	for variacao in banco_de_pecas.variacoes_disponiveis:
		var eh_valido = false
		if variacao and variacao.tipo and variacao.tipo.id == id_tipo_selecionado:
			eh_valido = true
		
		if eh_valido:
			var botao = BOTAO_VARIACAO_PECA.instantiate()
			botao.resource_variacao = variacao
			
			botao.icon = null
			botao.theme = THEME_BOTAO_NAO_SELECIONADO
			
			grid_variacoes.add_child(botao)
