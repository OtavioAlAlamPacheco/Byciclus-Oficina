extends Node3D

var selecao_multipla: bool = false

# dict usado pra posicionar as peças
var mapa_de_sockets: Dictionary = {
	#	"socket_selim": pai_do_socket
}

var instancias_ativas: Dictionary = {
	#"tipo": (instancia_da_peca)
}


func seleciona_pecas(ids: Array):
	selecao_multipla = true
	for id in ids:
		if id is String:
			seleciona_peca(id)
	
	_montar_bike()
	selecao_multipla = false


func seleciona_peca(id: String):
	var id_tipo
	if CatalogoPecas.resource_das_variacoes[id].tipo:
		id_tipo = CatalogoPecas.resource_das_variacoes[id].tipo.id
	var glb = CatalogoPecas.resource_das_variacoes[id].glb
	
	# remover antiga instância
	if instancias_ativas.has(id_tipo) and instancias_ativas[id_tipo] != null:
		print("Substituindo peça do tipo: ", id_tipo)
		var peca_antiga = instancias_ativas[id_tipo]
		peca_antiga.queue_free()
		instancias_ativas.erase(id_tipo)
		
	var nova_instancia = glb.instantiate()
	
	add_child(nova_instancia)
	instancias_ativas[id_tipo] = nova_instancia
	
	if not selecao_multipla:
		_montar_bike()


func _montar_bike():
	print("MONTANDO BIKE:")
	mapa_de_sockets.clear()
	_mapear_sockets()
	_posiciona_as_pecas()


func _mapear_sockets():
	for tipo in instancias_ativas:
		var peca = instancias_ativas[tipo]
		if is_instance_valid(peca):
			_escanear_sockets_na_peca(peca)

func _escanear_sockets_na_peca(peca: Node3D):
	if peca.get_child_count() > 0:
		var mesh = peca.get_child(0)
		
		for nodo in mesh.get_children():
			if nodo.has_meta("extras"):
				var info = nodo.get_meta("extras")
				
				if info is Dictionary and info.has("socket"):
					mapa_de_sockets[info["socket"]] = nodo
					print("Socket mapeado: ", info["socket"], " em ", peca.name)


func _posiciona_as_pecas() -> void:
	for tipo in instancias_ativas:
		var peca = instancias_ativas[tipo]
		
		print("\nPOSICIONANDO A PECA ", peca)
		
		if peca.get_child_count() > 0:
			var filho = peca.get_child(0)
			
			if filho.has_meta("extras"):
				var extras = filho.get_meta("extras")
				
				if extras is Dictionary and extras.has("socket_da_origem"):
					var alvo = extras["socket_da_origem"]
					
					if mapa_de_sockets.has(alvo):
						var nodo_destino = mapa_de_sockets[alvo]
						
						peca.reparent(nodo_destino)
						peca.transform = Transform3D.IDENTITY
						
						print("Peça ", peca.name, " \t\tconectada ao socket \t\t ", alvo)
					else:
						# os quadros são posicionados na origem da cena. Por isso eles não tem socket_da_origem
						if tipo != "Quadro":
							print("Socket alvo '", alvo, "' não encontrado no mapa atual.")
				else:
					if extras is Dictionary and extras.has("proxy"):
						print("Encontrou um proxy em: ", filho)
					else:
						print("PROBLEMA: A parte ", filho, " não tinha um extra 'socket_da_origem' e nem um 'proxy'.")
			else:
				print("O primeiro filho não tem o meta 'extras'. O filho é: ", filho)
		else:
			print("Essa peça não tem filhos. Peça: ", peca)
