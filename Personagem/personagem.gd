
@tool
extends Node3D

const blend_shapes: Array = ["Robustez", "Genero", "Formato do queixo",
	 "Profundidade do nariz", "Tamanho da orelha"]

@export var eh_preview: bool = false
var id_personagem: String = "Jogador"

var banco_de_estilos: Resource = preload("uid://drru2gl1lk2r0")

@onready var malha_3d: MeshInstance3D = $Armature/Skeleton3D/Personagem
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var malha_cabelo: Node3D
var minha_aparencia: Dictionary = {}


func _ready() -> void:
	#tocar_animacao("Idle balançar braços", true)
	
	if eh_preview:
		var customizacao = get_tree().get_first_node_in_group("customizacao_personagem")
		if customizacao:
			customizacao.preview_alterado.connect(equipar_estilo)
			equipar_visual_completo(customizacao.estilos_em_edicao)
		return
	
	else:
		PerfilPersonagem.aparencia_atualizada.connect(_on_atualizar_aparencia)
		var aparencia = PerfilPersonagem.carregar_perfil(
			"Jogador" if id_personagem == "Jogador" else "NPC",
			id_personagem
		)
		equipar_visual_completo(aparencia)


func tocar_animacao(nome_animacao: String, em_loop: bool) -> void:
	if not animation_player:
		push_error("AnimationPlayer não encontrado no personagem.")
		return
	
	if animation_player.has_animation(nome_animacao):
		var animacao = animation_player.get_animation(nome_animacao)
		
		if em_loop:
			animacao.loop_mode = Animation.LOOP_LINEAR
		else:
			animacao.loop_mode = Animation.LOOP_NONE
			
		animation_player.play(nome_animacao)
			
	else:
		push_error("Animação não mapeada: ", nome_animacao)


func parar_animacao() -> void:
	if animation_player and animation_player.is_playing():
		animation_player.stop()


func _on_atualizar_aparencia() -> void:
	var aparencia = PerfilPersonagem.carregar_perfil(
		"Jogador" if id_personagem == "Jogador" else "NPC",
		id_personagem
	)
	equipar_visual_completo(aparencia)


func atualizar_mesh_cabelo(cena_cabelo: PackedScene) -> void:
	var socket_cabelo = $Armature/Skeleton3D/SocketCabelo
	
	for filho in socket_cabelo.get_children():
		filho.queue_free()
	
	malha_cabelo = null
	
	if not cena_cabelo:
		return
		
	var novo_cabelo = cena_cabelo.instantiate()
	socket_cabelo.add_child(novo_cabelo)
	arruma_posicao_cabelo(novo_cabelo, socket_cabelo)
	
	malha_cabelo = novo_cabelo.get_child(0)


func arruma_posicao_cabelo(cabelo: Node3D, socket_cabelo):
	var skeleton: Skeleton3D = $Armature/Skeleton3D
	var bone_idx: int = skeleton.find_bone(socket_cabelo.bone_name)
	
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
	if not malha_3d:
		return false
	
	if not malha_3d.get_surface_override_material(0):
		if malha_3d.mesh and malha_3d.mesh.get_surface_count() > 0:
			var mat_original = malha_3d.mesh.surface_get_material(0)
			if mat_original:
				malha_3d.set_surface_override_material(0, mat_original.duplicate())
			else:
				return false
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
	
	match categoria:
		"Olhos":
			material.set_shader_parameter("textura_olhos", textura)
		"Nariz":
			material.set_shader_parameter("textura_nariz", textura)
		"Boca":
			material.set_shader_parameter("textura_boca", textura)
		"Detalhe1":
			material.set_shader_parameter("textura_detalhe_rosto_1", textura)
		"Detalhe2":
			material.set_shader_parameter("textura_detalhe_rosto_2", textura)


# aplica texturas e máscaras de roupas no shader
func _atualizar_roupa(categoria: String, valor: Variant, material: Material) -> void:
	var textura: Texture2D = null
	var mascara: Texture2D = null
	
	if valor != "Nenhum":
		textura = banco_de_estilos.obter_recurso(valor, categoria) as Texture2D
		if not textura:
			return
		
		mascara = banco_de_estilos.mascaras_por_tipo.get(categoria, null)
	
	match categoria:
		"Camisa", "Camiseta":
			material.set_shader_parameter("textura_camisa", textura)
			material.set_shader_parameter("mask_camisa", mascara)
		"Calça", "Bermuda":
			material.set_shader_parameter("textura_calca", textura)
			material.set_shader_parameter("mask_calca", mascara)
		"Casaco":
			material.set_shader_parameter("textura_casaco", textura)
			material.set_shader_parameter("mask_casaco", mascara)
		"Calçado":
			material.set_shader_parameter("textura_bota", textura)
			material.set_shader_parameter("mask_bota", mascara)
