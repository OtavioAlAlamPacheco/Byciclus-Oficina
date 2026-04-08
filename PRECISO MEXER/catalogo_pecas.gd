extends Node

var path_das_variacoes: String = "res://Resources/Variação de peça/"

var debugar: bool = true

var resource_das_variacoes: Dictionary = {
	# "id_variacao": resource_variacao
	
	# o resource já tem o ID, mas vou fazer assim pra fazer um acesso por dict,
	# que é mais rápido do que busca em array
}

var variacoes_por_tipo = {
	#	"id_tipo": ["resource_variacao_1", "resource_variacao_2", ...]
}

func catalogar_variacoes():
	var dir = DirAccess.open(path_das_variacoes)
	if not dir:
		print("ERRO: não foi possível abrir o diretório '", path_das_variacoes, "'")
		return
	
	dir.list_dir_begin()
	var arquivo = dir.get_next()
	
	while arquivo != "":
		if arquivo.get_extension() != "tres":
			if debugar:
				print("Arquivo ", arquivo, " não era um .tres. Pulando arquivo")
			
			arquivo = dir.get_next()
			continue
		
		var path_variacao = path_das_variacoes + arquivo + "/"
		var variacao = load(path_variacao)
		
		if variacao:
			resource_das_variacoes[variacao.id] = variacao
			
			if variacao.tipo != null:
				var id_tipo = variacao.tipo.id
				
				if not variacoes_por_tipo.has(id_tipo):
					variacoes_por_tipo[id_tipo] = []
				
				if not variacao.id in variacoes_por_tipo[id_tipo]:
					variacoes_por_tipo[id_tipo].append(variacao.id)
			elif debugar:
				print("A peça ", variacao.id, " não possui um resource Tipo")
		
		arquivo = dir.get_next()
	
	if debugar:
		print("FIM: Variações por tipo: ", variacoes_por_tipo)
