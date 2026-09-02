
extends Node3D

var selecao_multipla: bool = false

# dict usado pra posicionar as peças
var mapa_de_sockets: Dictionary = {
	#	"socket_selim": pai_do_socket
}

var pecas_instanciadas: Array[PecaInstanciadaData]


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
	var resource_variacao = CatalogoPecas.resource_das_variacoes[id]
	var id_tipo = ""
	if resource_variacao.tipo:
		id_tipo = resource_variacao.tipo.id
		
	for peca_data in pecas_instanciadas:
		if is_instance_valid(peca_data.instancia) and peca_data.instancia.get_parent() != self:
			peca_data.instancia.reparent(self)
			peca_data.instancia.transform = Transform3D.IDENTITY
	
	for i in range(pecas_instanciadas.size() - 1, -1, -1):
		var peca = pecas_instanciadas[i]
		
		if peca.resource_tipo and peca.resource_tipo.id == id_tipo:
			print("Substituindo peça do tipo: ", id_tipo)
			
			if is_instance_valid(peca.instancia):
				peca.instancia.queue_free()
			
			pecas_instanciadas.remove_at(i)
			
	if id_tipo == "Roda":
		_instanciar_nova_peca(resource_variacao, "roda_frontal")
		_instanciar_nova_peca(resource_variacao, "roda_traseira")
	else:
		_instanciar_nova_peca(resource_variacao)
	
	var tipo_atual = resource_variacao.tipo
	if tipo_atual and "tipo_sincronizado" in tipo_atual and tipo_atual.tipo_sincronizado != null:
		var id_tipo_origem = tipo_atual.id
		var id_tipo_destino = tipo_atual.tipo_sincronizado.id
		if CatalogoPecas.variacoes_por_tipo.has(id_tipo_origem) and CatalogoPecas.variacoes_por_tipo.has(id_tipo_destino):
			var index = CatalogoPecas.variacoes_por_tipo[id_tipo_origem].find(id)
			if index != -1 and index < CatalogoPecas.variacoes_por_tipo[id_tipo_destino].size():
				var id_variacao_destino = CatalogoPecas.variacoes_por_tipo[id_tipo_destino][index]
				var era_multipla = selecao_multipla
				selecao_multipla = true
				seleciona_peca(id_variacao_destino)
				selecao_multipla = era_multipla
	
	if not selecao_multipla:
		_montar_bike()


func _instanciar_nova_peca(resource_variacao, alvo_roda: String = "") -> void:
	var cena_mesh = resource_variacao.cena_mesh
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
	mapa_de_sockets.clear()
	_escanear_sockets()
	_posiciona_as_pecas()


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
						print("Encontrou um proxy em: ", filho, " (os proxys eram para os fios, mas precisei remover eles)")
					else:
						push_error("A parte da bike '", filho, "' não tinha um extra 'socket_da_origem' e nem um 'proxy'")



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

func obter_backup_peca(id_tipo: String) -> Dictionary:
	var backup = {}
	for peca in pecas_instanciadas:
		if peca.resource_tipo.id == id_tipo:
			backup["id_variacao"] = peca.resource_variacao.id
			backup["materiais"] = peca.materiais_aplicados.duplicate()
			return backup
	return backup


func restaurar_materiais_do_backup(backup: Dictionary) -> void:
	if not backup.has("id_variacao") or not backup.has("materiais"):
		return
		
	for slot_idx in backup["materiais"]:
		aplicar_material(backup["id_variacao"], backup["materiais"][slot_idx], slot_idx)

func aplicar_material(id_variacao: String, material: Material, slot_index: int) -> void:
	for peca_data in pecas_instanciadas:
		if peca_data.resource_variacao.id == id_variacao:
			peca_data.materiais_aplicados[slot_index] = material
			if is_instance_valid(peca_data.instancia):
				_aplicar_material_no_nodo(peca_data.instancia, material, slot_index)
				
	var resource_var = CatalogoPecas.resource_das_variacoes.get(id_variacao)
	if resource_var and resource_var.tipo:
		if "tipo_sincronizado" in resource_var.tipo and resource_var.tipo.tipo_sincronizado != null:
			var id_tipo_destino = resource_var.tipo.tipo_sincronizado.id
			var id_variacao_alvo = obter_variacao_ativa_do_tipo(id_tipo_destino)
			if id_variacao_alvo != "":
				aplicar_material(id_variacao_alvo, material, slot_index)
				
		if "sincronizar_material_com_tipo" in resource_var.tipo and resource_var.tipo.sincronizar_material_com_tipo != null:
			var id_tipo_alvo = resource_var.tipo.sincronizar_material_com_tipo.id
			var id_variacao_alvo = obter_variacao_ativa_do_tipo(id_tipo_alvo)
			if id_variacao_alvo != "":
				var slot_calculado = slot_index + resource_var.tipo.offset_de_slot_sincronizado
				aplicar_material(id_variacao_alvo, material, slot_calculado)

func _aplicar_material_no_nodo(nodo: Node, material: Material, slot_idx: int) -> void:
	for filho in nodo.get_children():
		if filho is MeshInstance3D:
			if slot_idx < filho.mesh.get_surface_count():
				filho.set_surface_override_material(slot_idx, material)
		else:
			_aplicar_material_no_nodo(filho, material, slot_idx)


func obter_dados_da_bike() -> Dictionary:
	var dados = {}
	for peca in pecas_instanciadas:
		if not is_instance_valid(peca.instancia):
			continue
			
		var id_tipo = peca.resource_tipo.id
		dados[id_tipo] = {
			"variacao": peca.resource_variacao.id,
			"materiais": peca.materiais_aplicados.duplicate()
		}
		
	return dados

func carregar_dados_da_bike(dados: Dictionary) -> void:
	var ids_variacoes = []
	for id_tipo in dados:
		if dados[id_tipo].has("variacao"):
			ids_variacoes.append(dados[id_tipo]["variacao"])
			
	seleciona_pecas(ids_variacoes)
	
	for id_tipo in dados:
		if dados[id_tipo].has("variacao") and dados[id_tipo].has("materiais"):
			var id_variacao = dados[id_tipo]["variacao"]
			var materiais_salvos = dados[id_tipo]["materiais"]
			
			for slot_idx in materiais_salvos:
				var material = materiais_salvos[slot_idx]
				aplicar_material(id_variacao, material, int(slot_idx))
