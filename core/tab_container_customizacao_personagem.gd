
extends TabContainer

@onready var customizacao_personagem = get_tree().get_first_node_in_group("customizacao_personagem")

func _ready() -> void:
	_atualizar_visibilidade_abas()


func _atualizar_visibilidade_abas() -> void:
	var tipo_customizacao = customizacao_personagem.tipo
	
	var aba_geral = 0
	var aba_cabelo = 1
	var aba_roupas = 2
	var aba_expressoes = 3
	
	if tipo_customizacao == "Jogador base":
		set_tab_hidden(aba_geral, false)
		set_tab_hidden(aba_cabelo, false)
		set_tab_hidden(aba_roupas, false)
		set_tab_hidden(aba_expressoes, true)
		current_tab = aba_geral
		
	elif tipo_customizacao == "Jogador estilo":
		set_tab_hidden(aba_geral, true)
		set_tab_hidden(aba_cabelo, false)
		set_tab_hidden(aba_roupas, false)
		set_tab_hidden(aba_expressoes, true)
		current_tab = aba_cabelo
		
	elif tipo_customizacao == "NPC":
		set_tab_hidden(aba_geral, false)
		set_tab_hidden(aba_cabelo, false)
		set_tab_hidden(aba_roupas, false)
		set_tab_hidden(aba_expressoes, false)
		current_tab = aba_geral
