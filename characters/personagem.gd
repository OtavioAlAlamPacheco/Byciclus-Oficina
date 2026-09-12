
@tool
extends Node3D

const blend_shapes: Array = ["Robustez", "Genero", "Formato do queixo",
	 "Profundidade do nariz", "Tamanho da orelha"]

@export var eh_preview: bool = false
@export var id_personagem: String = "Jogador":
	set(valor):
		id_personagem = valor
		if is_node_ready() and not eh_preview:
			_on_atualizar_aparencia()

@export_group("Path dos nodos")
@export var malha_3d: MeshInstance3D
@export var animation_player: AnimationPlayer
@export var socket_cabelo: Node3D

var banco_de_estilos: Resource = preload("uid://drru2gl1lk2r0")

var malha_cabelo: Node3D
var minha_aparencia: Dictionary = {}


func _ready() -> void:
	if eh_preview:
		var customizacao = get_tree().get_first_node_in_group("customizacao_personagem")
		if customizacao:
			customizacao.preview_alterado.connect(equipar_estilo)
			equipar_visual_completo(customizacao.estilos_em_edicao)
		return
	
	else:
		PerfilPersonagem.aparencia_atualizada.connect(_on_atualizar_aparencia)
		_on_atualizar_aparencia()


func tocar_animacao(nome_animacao: String, em_loop: bool) -> void:
	if not animation_player:
		push_error("AnimationPlayer não encontrado no personagem.")
		return
	
	if animation_player.has_animation(nome_animacao):
		var animacao = animation_player.get_animation(nome_animacao)
		
		animacao.loop_mode = Animation.LOOP_LINEAR if em_loop else Animation.LOOP_NONE
		
		animation_player.play(nome_animacao)
	
	else:
		push_error("Animação não mapeada: ", nome_animacao)


func parar_animacao() -> void:
	if animation_player and animation_player.is_playing():
		animation_player.stop()


func _on_atualizar_aparencia() -> void:
	var tipo = "Jogador" if id_personagem.to_lower() == "jogador" else "NPC"
	var dados_carregados = PerfilPersonagem.carregar_perfil(tipo, id_personagem)
	var aparencia = dados_carregados.get("aparencia", {})
	equipar_visual_completo(aparencia)


func atualizar_mesh_cabelo(cena_cabelo: PackedScene) -> void:
	if not socket_cabelo:
		return
	
	for filho in socket_cabelo.get_children():
		filho.queue_free()
	
	malha_cabelo = null
	
	if not cena_cabelo:
		return
		
	var novo_cabelo = cena_cabelo.instantiate()
	socket_cabelo.add_child(novo_cabelo)
	arruma_posicao_cabelo(novo_cabelo, socket_cabelo)
	
	if novo_cabelo is MeshInstance3D:
		malha_cabelo = novo_cabelo
	elif novo_cabelo.get_child_count() > 0:
		malha_cabelo = novo_cabelo.find_child("*", true, false) as MeshInstance3D


func arruma_posicao_cabelo(cabelo: Node3D, socket_ref: Node3D):
	var skeleton: Skeleton3D = socket_ref.get_parent() as Skeleton3D
	if not skeleton:
		return

	var bone_name: String = ""
	if "bone_name" in socket_ref:
		bone_name = socket_ref.bone_name
		
	var bone_idx: int = skeleton.find_bone(bone_name)
	
	if bone_idx != -1:
		var rest_transform: Transform3D = skeleton.get_bone_rest(bone_idx)
		var parent_idx: int = skeleton.get_bone_parent(bone_idx)
		
		# itera por todos os ossos pais para calcular o Rest Pose Global do osso da cabeça
		while parent_idx >= 0:
			rest_transform = skeleton.get_bone_rest(parent_idx) * rest_transform
			parent_idx = skeleton.get_bone_parent(parent_idx)
			
		# aplica a transformação inversa no cabelo para anular a rotação/offset do osso
		cabelo.transform = rest_transform.affine_inverse()


func equipar_visual_completo(dicionario: Dictionary) -> void:
	minha_aparencia = dicionario.duplicate()
	for tipo in minha_aparencia:
		var nome_estilo = minha_aparencia[tipo]
		if nome_estilo is not String or nome_estilo != "":
			equipar_estilo(tipo, nome_estilo)


func equipar_estilo(categoria: String, valor: Variant) -> void:
	minha_aparencia[categoria] = valor
	
	if categoria == "Nome Personagem":
		return
	elif categoria in blend_shapes or categoria == "Genero":
		_atualizar_blend_shapes(categoria, valor)
		return
	elif categoria == "Cabelo":
		_atualizar_cabelo(valor)
		return
	
	if not _garantir_material_unico():
		return
		
	var material = malha_3d.get_surface_override_material(0)
	
	if categoria in ["Cor Cabelo", "Cor Pele"]:
		_atualizar_cores(categoria, valor, material)
	elif categoria in ["Olhos", "Nariz", "Boca", "Detalhe1", "Detalhe2"]:
		_atualizar_textura_rosto(categoria, valor, material)
	elif categoria in ["Camisa", "Camiseta", "Calça", "Bermuda", "Casaco", "Calçado"]:
		_atualizar_roupa(categoria, valor, material)


# aplica os blend shapes do corpo e rosto
func _atualizar_blend_shapes(categoria: String, valor: Variant) -> void:
	if not malha_3d:
		return

	var nome_blend_shape = "Genero" if categoria == "Genero" else categoria
	var blend_shape_index = malha_3d.find_blend_shape_by_name(nome_blend_shape)
	
	if blend_shape_index != -1:
		if nome_blend_shape == "Genero":
			if valor == "Feminino":
				malha_3d.set_blend_shape_value(blend_shape_index, 0.0)
			elif valor == "Masculino":
				malha_3d.set_blend_shape_value(blend_shape_index, 1.0)
		else:
			malha_3d.set_blend_shape_value(blend_shape_index, float(valor))


func _atualizar_cabelo(valor: Variant) -> void:
	if valor == "Nenhum":
		atualizar_mesh_cabelo(null)
		return
	
	var cena_cabelo = banco_de_estilos.obter_recurso(valor, "Cabelo") as PackedScene
	atualizar_mesh_cabelo(cena_cabelo)
	
	var cor_atual = minha_aparencia.get("Cor Cabelo", "")
	equipar_estilo("Cor Cabelo", cor_atual)


func _garantir_material_unico() -> bool:
	if not malha_3d or not malha_3d.mesh or malha_3d.mesh.get_surface_count() == 0:
		return false
	
	var mat_atual = malha_3d.get_surface_override_material(0)
	
	if mat_atual:
		if mat_atual.resource_path != "":
			# se não duplicar, faz todos os personagens usarem o mesmo shader
			malha_3d.set_surface_override_material(0, mat_atual.duplicate())
	else:
		var mat_original = malha_3d.mesh.surface_get_material(0)
		if mat_original:
			malha_3d.set_surface_override_material(0, mat_original.duplicate())
		else:
			return false
	
	return true


# aplica cores nos parâmetros do shader
func _atualizar_cores(categoria: String, valor: Variant, material: Material) -> void:
	if valor is String and valor == "":
		return
	
	var cor = valor if valor is Color else Color(valor)
	
	if categoria == "Cor Cabelo":
		material.set_shader_parameter("cor_do_cabelo", cor)
		
		if is_instance_valid(malha_cabelo):
			if malha_cabelo is MeshInstance3D:
				var material_cabelo = malha_cabelo.get_surface_override_material(0)
				if not material_cabelo and malha_cabelo.mesh and malha_cabelo.mesh.get_surface_count() > 0:
					material_cabelo = malha_cabelo.mesh.surface_get_material(0).duplicate()
					malha_cabelo.set_surface_override_material(0, material_cabelo)

				if material_cabelo:
					material_cabelo.albedo_color = cor
				
	elif categoria == "Cor Pele":
		material.set_shader_parameter("cor_pele", cor)


func _atualizar_textura_rosto(categoria: String, valor: Variant, material: Material) -> void:
	var textura: Texture2D = null
	
	if valor != "Nenhum":
		textura = banco_de_estilos.obter_recurso(valor, categoria) as Texture2D
		if not textura:
			return
	
	var parametros_shader = {
		"Olhos": "textura_olhos", "Nariz": "textura_nariz", 
		"Boca": "textura_boca", "Detalhe1": "textura_detalhe_rosto_1", 
		"Detalhe2": "textura_detalhe_rosto_2"
	}
	
	if parametros_shader.has(categoria):
		material.set_shader_parameter(parametros_shader[categoria], textura)


# aplica texturas e máscaras de roupas no shader
func _atualizar_roupa(categoria: String, valor: Variant, material: Material) -> void:
	var textura: Texture2D = null
	var mascara: Texture2D = null
	
	if valor != "Nenhum":
		textura = banco_de_estilos.obter_recurso(valor, categoria) as Texture2D
		if not textura:
			return
		
		mascara = banco_de_estilos.mascaras_por_tipo.get(categoria, null)
	
	var parametros_shader = {
		"Camisa": ["textura_camisa", "mask_camisa"], "Camiseta": ["textura_camisa", "mask_camisa"],
		"Calça": ["textura_calca", "mask_calca"], "Bermuda": ["textura_calca", "mask_calca"],
		"Casaco": ["textura_casaco", "mask_casaco"], "Calçado": ["textura_bota", "mask_bota"]
	}
	
	if parametros_shader.has(categoria):
		material.set_shader_parameter(parametros_shader[categoria][0], textura)
		material.set_shader_parameter(parametros_shader[categoria][1], mascara)
