
extends Node3D

var pecas_instanciadas: Array[PecaInstanciadaData]


func _on_oficina_variacao_foi_selecionada(id: String) -> void:
	seleciona_peca(id)


func seleciona_peca(id: String):
	var resource_variacao = CatalogoPecas.resource_das_variacoes[id]
	var id_tipo = ""
	
	if resource_variacao.tipo:
		id_tipo = resource_variacao.tipo.id
	
	for peca in pecas_instanciadas:
		if is_instance_valid(peca.instancia):
			peca.instancia.queue_free()
			
	pecas_instanciadas.clear()
	
	var cena_mesh = resource_variacao.cena_mesh
	var nova_instancia = cena_mesh.instantiate()
	add_child(nova_instancia)
	
	nova_instancia.transform = Transform3D.IDENTITY
	
	var peca = PecaInstanciadaData.new()
	peca.instancia = nova_instancia
	peca.resource_tipo = CatalogoPecas.resource_dos_tipos[id_tipo]
	peca.resource_variacao = resource_variacao
	pecas_instanciadas.append(peca)
