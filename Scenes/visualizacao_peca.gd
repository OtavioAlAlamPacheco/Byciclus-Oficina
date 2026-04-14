

# instancia apenas a peça atualmente selecionada no menu de
# seleção de variação

extends Node3D

@onready var menu_variacao_peca: Panel = $"../CanvasLayer/InterfaceMenuOficina/MargemPrincipal/PaineisSuperiores/MenuSelecaoVariacaoPeca"

var id_variacao: String

func _ready() -> void:
	await get_tree().process_frame
	print("-------------------- READY DO VISUALIZACAO_PECA (com await) --------------------")
	var id = menu_variacao_peca.id_variacao_selecionada
	muda_variacao(id)

func muda_variacao(id: String):
	if get_child_count() == 0:
		return
	
	var antiga_instancia = get_child(0)
	if is_instance_valid(antiga_instancia):
		antiga_instancia.queue_free()
	
	print("CatalogoPecas.resource_das_variacoes: ", CatalogoPecas.resource_das_variacoes)
	print("CatalogoPecas.resource_das_variacoes[id]: ", CatalogoPecas.resource_das_variacoes[id])
	print("CatalogoPecas.resource_das_variacoes[id].cena_mesh : ", CatalogoPecas.resource_das_variacoes[id].cena_mesh)
	var nova_instancia = CatalogoPecas.resource_das_variacoes[id].cena_mesh
	print("\n\nCENA MESH: ", nova_instancia)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("teste"):
		var cena = CatalogoPecas.resource_das_variacoes["Roda frontal padrão"].cena_mesh
		var id = CatalogoPecas.resource_das_variacoes["Roda frontal padrão"].id
		print("Instanciando a peca ", id)
		var nova_instancia = cena.instantiate()
		add_child(nova_instancia)
