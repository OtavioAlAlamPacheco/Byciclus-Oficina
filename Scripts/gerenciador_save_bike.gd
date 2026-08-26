
class_name GerenciadorSaveBikes
extends RefCounted

const CAMINHO_SAVE = "user://Config Files/bicicletas_salvas.cfg"

static func salvar_bike(id_bike: String, dados_das_pecas: Dictionary) -> void:
	print("\nSalvando a bike: ", id_bike)
	_escrever_arquivo("Garagem", id_bike, dados_das_pecas)

static func carregar_bike(id_bike: String) -> Dictionary:
	return _ler_arquivo("Garagem", id_bike)

static func carregar_todas_as_bikes() -> Dictionary:
	var config = ConfigFile.new()
	var erro = config.load(CAMINHO_SAVE)
	var todas_as_bikes = {}
	
	if erro == OK and config.has_section("Garagem"):
		for chave in config.get_section_keys("Garagem"):
			todas_as_bikes[chave] = config.get_value("Garagem", chave)
			
	return todas_as_bikes

static func _escrever_arquivo(secao: String, chave: String, dados: Dictionary) -> void:
	var config = ConfigFile.new()
	config.load(CAMINHO_SAVE)
	
	config.set_value(secao, chave, dados)
	
	var dir = CAMINHO_SAVE.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	var erro = config.save(CAMINHO_SAVE)
	if erro != OK:
		push_error("Erro ao salvar o arquivo da bike. Código: ", erro)
	else:
		print("Bike salva com sucesso no arquivo .cfg.")

static func _ler_arquivo(secao: String, chave: String) -> Dictionary:
	var config = ConfigFile.new()
	var erro = config.load(CAMINHO_SAVE)
	
	if erro == OK:
		return config.get_value(secao, chave, {})
	
	return {}
