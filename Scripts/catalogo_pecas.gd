

extends Node

var path_das_variacoes: String = "res://Resources/Variação de peça/"
var path_dos_tipos: String = "res://Resources/Tipo de peça/"

var variacoes_por_tipo: Dictionary = {
	#	"id_tipo": ["resource_variacao_1", "resource_variacao_2", ...]
}

# os resources já tem o id. Porém, vou criar esses dict pra poder fazer acesso
# direto por valor

var resource_das_variacoes: Dictionary = {
	# "id_variacao": resource_variacao
}

var resource_dos_tipos: Dictionary = {
	# "id_tipo": resource_tipo
}

func _ready() -> void:
	print("-------------------- READY DO CATALOGO_PECAS --------------------")


func catalogar_tipos():
	var dir = DirAccess.open(path_dos_tipos)
	if not dir:
		print("ERRO: não foi possível abrir o diretório '", path_dos_tipos, "'")
		return
	
	dir.list_dir_begin()
	var arquivo = dir.get_next()
	
	while arquivo != "":
		if arquivo.get_extension() == "tres":
			var tipo_res = load(path_dos_tipos + arquivo + "/")
			if tipo_res:
				var id_t = tipo_res.id
				resource_dos_tipos[id_t] = tipo_res
				
				variacoes_por_tipo[id_t] = []
				for var_res in resource_das_variacoes.values():
					if var_res.tipo and var_res.tipo.id == id_t:
						variacoes_por_tipo[id_t].append(var_res.id)
		
		arquivo = dir.get_next()

func catalogar_variacoes():
	var dir = DirAccess.open(path_das_variacoes)
	if not dir:
		print("ERRO: não foi possível abrir o diretório '", path_das_variacoes, "'")
		return
	
	dir.list_dir_begin()
	var arquivo = dir.get_next()
	
	while arquivo != "":
		if arquivo.get_extension() == "tres":
			var variacao = load(path_das_variacoes + arquivo + "/")
			if variacao:
				resource_das_variacoes[variacao.id] = variacao
				
		arquivo = dir.get_next()
