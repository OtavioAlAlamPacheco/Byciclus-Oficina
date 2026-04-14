extends Node3D

var selecao_multipla: bool = false

# dict usado pra posicionar as peças
var mapa_de_sockets: Dictionary = {
	#	"socket_selim": pai_do_socket
}

# armazena PecaInstanciada (que tem 'instancia', 'resource_tipo' e 'resource_variacao')
var pecas_instanciadas: Array


func _ready() -> void:
	print("-------------------- READY DO VISUALIZACAO_BIKE --------------------")


func _on_oficina_variacao_foi_selecionada(id: String) -> void:
	seleciona_peca(id)


func seleciona_todas_pecas():
	selecao_multipla = true
	for id in CatalogoPecas.resource_das_variacoes:
		seleciona_peca(id)
	
	_montar_bike()
	selecao_multipla = false


func seleciona_pecas(ids: Array):
	selecao_multipla = true
	for id in ids:
		seleciona_peca(id)
	
	_montar_bike()
	selecao_multipla = false


func seleciona_peca(id: String):
	var peca
	var resource_variacao = CatalogoPecas.resource_das_variacoes[id]
	var id_tipo = ""
	if resource_variacao.tipo:
		id_tipo = resource_variacao.tipo.id
	
	# remover tipo antigo
	var i = 0
	while i < pecas_instanciadas.size():
		peca = pecas_instanciadas[i]
		
		if peca.resource_tipo and peca.resource_tipo.id == id_tipo:
			print("Substituindo peça do tipo: ", id_tipo)
			
			if is_instance_valid(peca.instancia):
				peca.instancia.queue_free()
			
			pecas_instanciadas.remove_at(i)
		else:
			i += 1
	
	var cena_mesh = resource_variacao.cena_mesh
	var nova_instancia = cena_mesh.instantiate()
	add_child(nova_instancia)
	
	print("\n\nNova_instancia: ", nova_instancia)
	
	peca = PecaInstanciada.new()
	peca.instancia = nova_instancia
	peca.resource_tipo = CatalogoPecas.resource_dos_tipos[id_tipo]
	peca.resource_variacao = resource_variacao
	pecas_instanciadas.append(peca)
	
	if not selecao_multipla:
		_montar_bike()


func _montar_bike():
	print("MONTANDO BIKE:")
	mapa_de_sockets.clear()
	_escanear_sockets()
	_posiciona_as_pecas()
	
	print("TODAS AS PEÇAS ATIVAS:")
	for peca in pecas_instanciadas:
		print("\n- Tipo: ", peca.resource_tipo.id)
		print("  Instancia: ", peca.instancia)
		print("  Variação: ", peca.resource_variacao.id)


func _escanear_sockets():
	for peca_data in pecas_instanciadas:
		var node_3d = peca_data.instancia
		if is_instance_valid(node_3d):
			_mapear_sockets_na_peca(node_3d)


func _mapear_sockets_na_peca(peca: Node3D):
	if peca.get_child_count() > 0:
		var mesh = peca.get_child(0)
		
		for nodo in mesh.get_children():
			if nodo.has_meta("extras"):
				var info = nodo.get_meta("extras")
				
				if info is Dictionary and info.has("socket"):
					mapa_de_sockets[info["socket"]] = nodo
					print("Socket mapeado: ", info["socket"], " em ", peca.name)


func _posiciona_as_pecas() -> void:
	for peca_data in pecas_instanciadas:
		var instancia = peca_data.instancia
		
		if not is_instance_valid(instancia):
			continue
			
		print("\nPOSICIONANDO A PECA ", instancia)
		
		if instancia.get_child_count() > 0:
			var filho = instancia.get_child(0)
			
			if filho.has_meta("extras"):
				var extras = filho.get_meta("extras")
				
				if extras is Dictionary and extras.has("socket_da_origem"):
					var alvo = extras["socket_da_origem"]
					
					if mapa_de_sockets.has(alvo):
						var nodo_destino = mapa_de_sockets[alvo]
						
						instancia.reparent(nodo_destino)
						instancia.transform = Transform3D.IDENTITY
						
						print("Peça ", instancia.name, " conectada ao socket ", alvo)
					else:
						print("Socket alvo '", alvo, "' não encontrado no mapa atual.")
				else:
					if extras is Dictionary and extras.has("proxy"):
						print("Encontrou um proxy em: ", filho)
					else:
						print("PROBLEMA: A parte ", filho, " não tinha um extra 'socket_da_origem' e nem um 'proxy'.")
			else:
				print("O primeiro filho não tem o meta 'extras'. O filho é: ", filho)
		else:
			print("Essa peça não tem filhos. Peça: ", instancia)
