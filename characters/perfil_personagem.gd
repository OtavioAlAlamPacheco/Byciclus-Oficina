
extends Node

signal aparencia_atualizada()

var banco_de_estilos: Resource = preload("uid://drru2gl1lk2r0")
var caminho_save: String = "user://Config Files/perfil_personagem.cfg"


func salvar_perfil(tipo: String, novo_nome: String, nova_aparencia: Dictionary):
	var dados_existentes = carregar_perfil(tipo, novo_nome)
	var aparencia_final = dados_existentes.get("aparencia", {}).duplicate()
	
	aparencia_final.merge(nova_aparencia, true)
	
	var nome_final = novo_nome
	if nome_final == "" or nome_final == "(Nome do personagem)":
		nome_final = dados_existentes.get("nome", novo_nome)
		
	var dados := {"nome": nome_final, "aparencia": aparencia_final}
	
	if tipo.begins_with("Jogador"):
		_escrever_arquivo("PerfilJogador", "Dados", dados)
		aparencia_atualizada.emit()
	elif tipo == "NPC" and nome_final != "":
		_escrever_arquivo("PerfilNPC", nome_final, dados)
	else:
		push_error("Erro ao salvar perfil do (", nome_final, "). Tipo do personagem era: ", tipo)


func carregar_perfil(tipo: String, nome_alvo: String = "") -> Dictionary:
	if tipo.to_lower().begins_with("jogador"):
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


func obter_nomes_npcs_salvos() -> Array:
	var nomes_encontrados: Array = []
	var config := ConfigFile.new()
	var erro = config.load(caminho_save)
	
	if erro == OK and config.has_section("PerfilNPC"):
		for chave in config.get_section_keys("PerfilNPC"):
			nomes_encontrados.append(chave)
			
	return nomes_encontrados
