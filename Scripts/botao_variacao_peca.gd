
@tool
extends Button

@export var resource_variacao: VariacaoPecaData:
	set(valor):
		resource_variacao = valor
		if is_inside_tree():
			_atualizar_malha_3d()

@onready var viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D

var malha_instanciada: Node3D

func _ready() -> void:
	if resource_variacao:
		_atualizar_malha_3d()


func _atualizar_malha_3d() -> void:
	if is_instance_valid(malha_instanciada):
		malha_instanciada.queue_free()
		
	for filho in viewport.get_children():
		if not (filho is Camera3D or filho is DirectionalLight3D or filho is WorldEnvironment):
			filho.queue_free()
			
	if resource_variacao and resource_variacao.cena_mesh:
		malha_instanciada = resource_variacao.cena_mesh.instantiate()
		viewport.add_child(malha_instanciada)
		
		if resource_variacao.tipo:
			camera.position = resource_variacao.tipo.posicao_camera
			camera.rotation = resource_variacao.tipo.rotacao_camera
			camera.keep_aspect = Camera3D.KEEP_WIDTH
		
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		await get_tree().process_frame
		await get_tree().process_frame
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _on_pressed() -> void:
	var nodo_oficina = get_tree().get_first_node_in_group("oficina")
	if nodo_oficina and nodo_oficina.has_method("solicitar_selecao_variacao"):
		nodo_oficina.solicitar_selecao_variacao(resource_variacao.id)
