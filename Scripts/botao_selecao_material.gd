
extends Button

var material_aplicado: Material
var variacao_peca: VariacaoPecaData
var indice_slot: int
var popup_pai: CanvasLayer
var malha_instanciada: Node3D

@onready var viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D

const THEME_BOTAO_NAO_SELECIONADO = preload("uid://btfmvlloabut6")
const THEME_BOTAO_SELECIONADO = preload("uid://cexiw2525vqhn")

func _ready() -> void:
	theme = THEME_BOTAO_NAO_SELECIONADO

func configurar_botao(material: Material, variacao: VariacaoPecaData, slot_index: int, popup_ref: CanvasLayer = null) -> void:
	material_aplicado = material
	variacao_peca = variacao
	indice_slot = slot_index
	popup_pai = popup_ref
	_atualizar_malha_3d()


func _atualizar_malha_3d() -> void:
	if is_instance_valid(malha_instanciada):
		malha_instanciada.queue_free()
		
	for filho in viewport.get_children():
		if not (filho is Camera3D or filho is DirectionalLight3D or filho is WorldEnvironment):
			filho.queue_free()
			
	if variacao_peca and variacao_peca.cena_mesh:
		malha_instanciada = variacao_peca.cena_mesh.instantiate()
		viewport.add_child(malha_instanciada)
		
		_aplicar_material_no_slot_da_foto(malha_instanciada, material_aplicado, indice_slot)
		
		if variacao_peca.tipo:
			camera.position = variacao_peca.tipo.posicao_camera
			camera.rotation = variacao_peca.tipo.rotacao_camera
			camera.keep_aspect = Camera3D.KEEP_WIDTH
		
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		await get_tree().process_frame
		await get_tree().process_frame
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _aplicar_material_no_slot_da_foto(nodo: Node, material: Material, slot_idx: int) -> void:
	for filho in nodo.get_children():
		if filho is MeshInstance3D:
			if slot_idx < filho.mesh.get_surface_count():
				filho.set_surface_override_material(slot_idx, material)
		else:
			_aplicar_material_no_slot_da_foto(filho, material, slot_idx)


func _on_pressed() -> void:
	var oficina = get_tree().get_first_node_in_group("oficina")
	if oficina and oficina.has_method("aplicar_material_na_bike"):
		oficina.aplicar_material_na_bike(variacao_peca.id, material_aplicado, indice_slot)
		
	if is_instance_valid(popup_pai) and popup_pai.has_method("registrar_preenchimento_de_slot"):
		popup_pai.registrar_preenchimento_de_slot(indice_slot)

func atualizar_tema(selecionado: bool) -> void:
	if selecionado:
		theme = THEME_BOTAO_SELECIONADO
	else:
		theme = THEME_BOTAO_NAO_SELECIONADO
	
	release_focus()
