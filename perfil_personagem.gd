
extends Node

signal aparencia_atualizada()

var banco_de_estilos: Resource = preload("uid://drru2gl1lk2r0")
var caminho_save: String = "user://Config Files/perfil_personagem.cfg"


func salvar_perfil(tipo: String, novo_nome: String, nova_aparencia: Dictionary):
	var dados := {"nome": novo_nome, "aparencia": nova_aparencia}
	
	if tipo == "Jogador":
		_escrever_arquivo("PerfilJogador", "Dados", dados)
		aparencia_atualizada.emit()
	elif tipo == "NPC" and novo_nome != "":
		_escrever_arquivo("PerfilNPC", novo_nome, dados)
	else:
		push_error("Erro ao salvar perfil do (", novo_nome, "). Tipo do personagem era: ", tipo)


func carregar_perfil(tipo: String, nome_alvo: String = "") -> Dictionary:
	if tipo == "Jogador":
		return _ler_arquivo("PerfilJogador", "Dados")
	elif tipo == "NPC":
		if nome_alvo != "":
			return _ler_arquivo("PerfilNPC", nome_alvo)
		else:
			print("Perfil não carregado, pois faltou fornecer o nome do npc")
	
	return {}


func _escrever_arquivo(secao: String, chave: String, dados: Dictionary):
	var config := ConfigFile.new()
	config.load(caminho_save)
	
	config.set_value(secao, chave, dados)
	
	var dir = caminho_save.get_base_dir()
	
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	var erro = config.save(caminho_save)
	if erro != OK:
		push_error("Erro ao salvar o arquivo. Código do erro: ", erro)
	else:
		print("Arquivo salvo com sucesso.")

func _ler_arquivo(secao: String, chave: String) -> Dictionary:
	var dados_padrao := {"nome": "(Nome do personagem)", "aparencia": {}}
	var config := ConfigFile.new()
	var erro = config.load(caminho_save)
	
	if erro == OK:
		return config.get_value(secao, chave, dados_padrao)
	
	return dados_padrao
