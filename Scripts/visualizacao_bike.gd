
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
	
	for id_tipo in CatalogoPecas.variacoes_por_tipo:
		var variacoes = CatalogoPecas.variacoes_por_tipo[id_tipo]
		if variacoes.size() > 0:
			seleciona_peca(variacoes[0])
	
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
		
	for peca_data in pecas_instanciadas:
		if is_instance_valid(peca_data.instancia) and peca_data.instancia.get_parent() != self:
			peca_data.instancia.reparent(self)
			peca_data.instancia.transform = Transform3D.IDENTITY
	
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
			
	if id_tipo == "Roda":
		_instanciar_nova_peca(resource_variacao, "roda_frontal")
		_instanciar_nova_peca(resource_variacao, "roda_traseira")
	else:
		_instanciar_nova_peca(resource_variacao)
	
	if not selecao_multipla:
		_montar_bike()


func _instanciar_nova_peca(resource_variacao, alvo_roda: String = "") -> void:
	var cena_mesh = resource_variacao.cena_mesh
	print("Vou tentar instanciar. Self: ", self, ". Resource_variacao: ", resource_variacao.id)
	var nova_instancia = cena_mesh.instantiate()
	add_child(nova_instancia)
	
	if alvo_roda != "" and nova_instancia.get_child_count() > 0:
		var mesh = nova_instancia.get_child(0)
		if mesh.has_meta("extras"):
			var extras = mesh.get_meta("extras").duplicate()
			extras["socket_da_origem"] = alvo_roda
			mesh.set_meta("extras", extras)
	
	var peca = PecaInstanciadaData.new()
	peca.instancia = nova_instancia
	peca.resource_tipo = CatalogoPecas.resource_dos_tipos[resource_variacao.tipo.id]
	peca.resource_variacao = resource_variacao
	pecas_instanciadas.append(peca)


func _montar_bike():
	print("MONTANDO BIKE:")
	mapa_de_sockets.clear()
	_escanear_sockets()
	_posiciona_as_pecas()
	
	print("TODAS AS PEÇAS ATIVAS:")
	for peca in pecas_instanciadas:
		print("\n- Tipo: ", peca.resource_tipo.id)
		print("	 Instancia: ", peca.instancia)
		print("	 Variação: ", peca.resource_variacao.id)


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



func obter_coordenada_da_peca(id_variacao: String) -> Variant:
	for peca_data in pecas_instanciadas:
		if peca_data.resource_variacao.id == id_variacao:
			if is_instance_valid(peca_data.instancia):
				return peca_data.instancia.global_position
	return null

func obter_variacao_ativa_do_tipo(id_tipo: String) -> String:
	for peca_data in pecas_instanciadas:
		if peca_data.resource_tipo.id == id_tipo:
			return peca_data.resource_variacao.id
	return ""




# ======================= Pra debug ==========================

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("teste"):
		_imprimir_relatorio_debug()

func _imprimir_relatorio_debug() -> void:
	print("\n========== RELATÓRIO DE DEBUG ==========")
	print("Total de nós filhos diretos da cena Bike: ", get_child_count())
	print("Total de peças na Array 'pecas_instanciadas': ", pecas_instanciadas.size())
	
	print("\n--- Filhos Diretos (Visuais) ---")
	for filho in get_children():
		print("- ", filho.name)
	
	print("\n--- Registro Lógico de Peças ---")
	for peca in pecas_instanciadas:
		if is_instance_valid(peca.instancia):
			var nome_pai = peca.instancia.get_parent().name if peca.instancia.get_parent() else "NENHUM"
			print("- [Válida] Tipo: ", peca.resource_tipo.id, " | Variação: ", peca.resource_variacao.id, " | Nó: ", peca.instancia.name, " | Pai atual: ", nome_pai)
		else:
			print("- [ALERTA - FANTASMA] Tipo: ", peca.resource_tipo.id, " (Instância foi deletada, mas segue no Array!)")
	print("========================================\n")
