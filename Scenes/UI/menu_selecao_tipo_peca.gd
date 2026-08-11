
extends Panel

const THEME_BOTAO_NAO_SELECIONADO = preload("uid://btfmvlloabut6")
const THEME_BOTAO_SELECIONADO = preload("uid://cexiw2525vqhn")

@onready var vbox_botoes: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	for botao in vbox_botoes.get_children():
		if botao is Button:
			botao.theme = THEME_BOTAO_NAO_SELECIONADO
			
			if not botao.pressed.is_connected(_on_botao_pressionado):
				botao.pressed.connect(_on_botao_pressionado.bind(botao))
	
	var primeiro_botao = vbox_botoes.get_child(0)
	primeiro_botao.theme = THEME_BOTAO_SELECIONADO

func _on_botao_pressionado(botao_clicado: Button) -> void:
	for botao in vbox_botoes.get_children():
		if botao is Button:
			botao.theme = THEME_BOTAO_NAO_SELECIONADO
			
	botao_clicado.theme = THEME_BOTAO_SELECIONADO

func atualizar_selecao_por_id(id_tipo: String) -> void:
	for botao in vbox_botoes.get_children():
		if botao is Button:
			if "resource_tipo" in botao and botao.resource_tipo and botao.resource_tipo.id == id_tipo:
				botao.theme = THEME_BOTAO_SELECIONADO
			else:
				botao.theme = THEME_BOTAO_NAO_SELECIONADO
