
extends Node

signal preview_alterado(categoria: String, valor: Variant)
signal perfil_carregado(aparencia: Dictionary)

@export_enum("Jogador", "NPC") var tipo: String = "Jogador"

@onready var personagem: Node3D = %PreviewPersonagem/Personagem

var estilos: Resource = preload("uid://drru2gl1lk2r0")
var nome_em_edicao: String = "(Nome do personagem)"
var estilos_em_edicao: Dictionary = {}


func _ready() -> void:
	#personagem.tocar_animacao("Idle balançar braços", true)
	
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
