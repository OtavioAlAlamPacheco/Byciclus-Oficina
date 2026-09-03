
extends Node

signal preview_alterado(categoria: String, valor: Variant)
signal perfil_carregado(aparencia: Dictionary)

@export_enum("Jogador base", "Jogador estilo", "NPC") var tipo: String = "Jogador base"

@onready var tab_container: TabContainer = %TabContainerPersonagem
@onready var linha_carregar_npc: Control = $"MarginContainer/HBoxContainer/AreaEsquerda/TabContainerPersonagem/Geral/MarginContainer/SelecaoGeral/MarginContainer/Opcoes/DEV - carregar NPC"
@onready var seletor_npc: OptionButton = $"MarginContainer/HBoxContainer/AreaEsquerda/TabContainerPersonagem/Geral/MarginContainer/SelecaoGeral/MarginContainer/Opcoes/DEV - carregar NPC/OptionButton"
@onready var personagem: Node3D = %PreviewPersonagem/Personagem

var estilos: Resource = preload("uid://drru2gl1lk2r0")
var nome_em_edicao: String = "(Nome do personagem)"
var estilos_em_edicao: Dictionary = {}


func _ready() -> void:
	_atualizar_visibilidade_abas()
	_selecionar_expressoes_base()
	_configurar_linha_npc()
	
	var nome_alvo = ""
	if tipo == "NPC":
		nome_alvo = nome_em_edicao
		
	var dados_carregados = PerfilPersonagem.carregar_perfil(tipo, nome_alvo)
	
	if dados_carregados.has("nome"):
		nome_em_edicao = dados_carregados["nome"]
		estilos_em_edicao["Nome Personagem"] = nome_em_edicao
		
	if dados_carregados.has("aparencia") and not dados_carregados["aparencia"].is_empty():
		estilos_em_edicao = dados_carregados["aparencia"].duplicate()
		estilos_em_edicao["Nome Personagem"] = nome_em_edicao
		
	_preencher_valores_padrao()
		
	personagem.equipar_visual_completo(estilos_em_edicao)
	
	call_deferred("_sincronizar_interface")


func _sincronizar_interface() -> void:
	perfil_carregado.emit(estilos_em_edicao)

func definir_tipo_personagem(novo_tipo: String) -> void:
	tipo = novo_tipo
	
	var nome_alvo = ""
	if tipo == "NPC":
		nome_alvo = nome_em_edicao
		
	var dados_carregados = PerfilPersonagem.carregar_perfil(tipo, nome_alvo)
	
	estilos_em_edicao.clear()
	
	if dados_carregados.has("nome") and dados_carregados.has("aparencia") and not dados_carregados["aparencia"].is_empty():
		nome_em_edicao = dados_carregados["nome"]
		estilos_em_edicao = dados_carregados["aparencia"].duplicate()
		estilos_em_edicao["Nome Personagem"] = nome_em_edicao
		
	_preencher_valores_padrao()
		
	personagem.equipar_visual_completo(estilos_em_edicao)
	perfil_carregado.emit(estilos_em_edicao)


func selecionar_estilo_local(categoria: String, valor: Variant) -> void:
	_atualizar_estilos_em_edicao(categoria, valor)
	preview_alterado.emit(categoria, valor)
	
	if categoria == "Camisa":
		preview_alterado.emit("Camiseta", "")
	elif categoria == "Camiseta":
		preview_alterado.emit("Camisa", "")
	elif categoria == "Calça":
		preview_alterado.emit("Bermuda", "")
	elif categoria == "Bermuda":
		preview_alterado.emit("Calça", "")


func _atualizar_estilos_em_edicao(categoria, valor):
	if categoria == "Nome Personagem":
		nome_em_edicao = valor
	elif categoria == "Camisa":
		estilos_em_edicao["Camiseta"] = ""
	elif categoria == "Camiseta":
		estilos_em_edicao["Camisa"] = ""
	elif categoria == "Calça":
		estilos_em_edicao["Bermuda"] = ""
	elif categoria == "Bermuda":
		estilos_em_edicao["Calça"] = ""
	
	estilos_em_edicao[categoria] = valor


func confirmar_alteracoes() -> void:
	_preencher_valores_padrao()
	PerfilPersonagem.salvar_perfil(tipo, nome_em_edicao, estilos_em_edicao)


func _preencher_valores_padrao() -> void:
	var categorias = [
		"Camisa", "Camiseta", "Calça", "Bermuda", "Casaco", "Calçado",
		"Cabelo", "Cor Cabelo", "Cor Pele", "Olhos", "Boca", "Nariz",
		"Detalhe1", "Detalhe2", "Robustez", "Formato do queixo",
		"Profundidade do nariz", "Tamanho da orelha", "Genero"
	]
	
	for categoria in categorias:
		if not estilos_em_edicao.has(categoria):
			if categoria in ["Robustez", "Formato do queixo", "Profundidade do nariz", "Tamanho da orelha"]:
				estilos_em_edicao[categoria] = 0.0
			elif categoria == "Cor Pele":
				estilos_em_edicao[categoria] = Color(0.82, 0.55, 0.37, 1.0)
			elif categoria == "Cor Cabelo":
				estilos_em_edicao[categoria] = Color(0.16, 0.10, 0.06, 1.0)
			elif categoria == "Genero":
				estilos_em_edicao[categoria] = "Masculino"
			elif categoria in ["Detalhe1", "Detalhe2", "Casaco"]:
				estilos_em_edicao[categoria] = "Nenhum"
			else:
				estilos_em_edicao[categoria] = ""


func _atualizar_visibilidade_abas() -> void:
	if not is_instance_valid(tab_container):
		return
		
	var aba_geral = 0
	var aba_cabelo = 1
	var aba_roupas = 2
	var aba_expressoes = 3
	
	if tipo == "Jogador base":
		tab_container.set_tab_hidden(aba_geral, false)
		tab_container.set_tab_hidden(aba_cabelo, false)
		tab_container.set_tab_hidden(aba_roupas, false)
		tab_container.set_tab_hidden(aba_expressoes, true)
		tab_container.current_tab = aba_geral
		
	elif tipo == "Jogador estilo":
		tab_container.set_tab_hidden(aba_geral, true)
		tab_container.set_tab_hidden(aba_cabelo, false)
		tab_container.set_tab_hidden(aba_roupas, false)
		tab_container.set_tab_hidden(aba_expressoes, true)
		tab_container.current_tab = aba_cabelo
		
	elif tipo == "NPC":
		tab_container.set_tab_hidden(aba_geral, false)
		tab_container.set_tab_hidden(aba_cabelo, false)
		tab_container.set_tab_hidden(aba_roupas, false)
		tab_container.set_tab_hidden(aba_expressoes, false)
		tab_container.current_tab = aba_geral

func _selecionar_expressoes_base() -> void:
	estilos_em_edicao["Boca"] = "uid://cctqonfb2nydq"
	estilos_em_edicao["Nariz"] = "uid://b3u03a8mfnmtb"
	estilos_em_edicao["Olhos"] = "uid://to102o7gyg5n"
	
	preview_alterado.emit("Boca", estilos_em_edicao["Boca"])
	preview_alterado.emit("Nariz", estilos_em_edicao["Nariz"])
	preview_alterado.emit("Olhos", estilos_em_edicao["Olhos"])


func _configurar_linha_npc() -> void:
	if not is_instance_valid(linha_carregar_npc) or not is_instance_valid(seletor_npc):
		return
		
	if tipo == "NPC":
		linha_carregar_npc.show()
		_popular_lista_npcs()
		
		if not seletor_npc.item_selected.is_connected(_on_npc_selecionado):
			seletor_npc.item_selected.connect(_on_npc_selecionado)
	else:
		linha_carregar_npc.hide()


func _popular_lista_npcs() -> void:
	seletor_npc.clear()
	seletor_npc.add_item("Selecione um NPC...")
	seletor_npc.set_item_disabled(0, true)
	
	var nomes = PerfilPersonagem.obter_nomes_npcs_salvos()
	for nome in nomes:
		seletor_npc.add_item(nome)
		
	seletor_npc.select(-1)


func _on_npc_selecionado(index: int) -> void:
	var nome_npc = seletor_npc.get_item_text(index)
	var dados_npc = PerfilPersonagem.carregar_perfil("NPC", nome_npc)
	
	if not dados_npc.is_empty():
		var aparencia_salva = dados_npc.get("aparencia", {})
		estilos_em_edicao = aparencia_salva.duplicate()
		
		nome_em_edicao = nome_npc
		estilos_em_edicao["Nome Personagem"] = nome_npc
		
		perfil_carregado.emit(estilos_em_edicao)
		
		for categoria in estilos_em_edicao:
			preview_alterado.emit(categoria, estilos_em_edicao[categoria])
