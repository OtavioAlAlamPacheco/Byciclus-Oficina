
extends Button

@onready var camera_preview_estilo: Camera3D = $SubViewportContainer/SubViewport/PreviewEstilo/Camera3D
@onready var customizacao_personagem: Control = get_tree().get_first_node_in_group("customizacao_personagem")

var estilos: Resource = preload("uid://drru2gl1lk2r0")
var nome_estilo: String
var tipo_estilo: String
var textura: Texture2D
var estilo_instanciado: Node3D


func _on_selecao_de_estilo() -> void:
	customizacao_personagem.selecionar_estilo_local(tipo_estilo, nome_estilo)


# essa função é usada pra instanciar o estilo dinamicamente na interface
func cria_o_estilo(nome: String, tipo: String, scene: PackedScene):
	nome_estilo = nome
	tipo_estilo = tipo
	
	var visual_selecionado = get_theme_stylebox("pressed", "Button")
	add_theme_stylebox_override("disabled", visual_selecionado)
	
	if not customizacao_personagem.perfil_carregado.is_connected(_sincronizar_botao):
		customizacao_personagem.perfil_carregado.connect(_sincronizar_botao)
	if not customizacao_personagem.preview_alterado.is_connected(_on_preview_alterado_geral):
		customizacao_personagem.preview_alterado.connect(_on_preview_alterado_geral)
		
	_atualizar_estado_botao()
	
	if nome == "Nenhum":
		if has_node("RemoverEstilo"):
			get_node("RemoverEstilo").show()
		return
	
	estilo_instanciado = _instanciar_cena(scene)
	_conectar_sinais(tipo)
	
	var malha_3d: MeshInstance3D = get_nodo_malha(estilo_instanciado)
	if malha_3d:
		_aplicar_material(malha_3d, nome, tipo)
		
	centraliza_a_camera(estilo_instanciado, tipo)


func _sincronizar_botao(aparencia: Dictionary) -> void:
	_atualizar_estado_botao()


func _on_preview_alterado_geral(categoria: String, valor: Variant) -> void:
	_atualizar_estado_botao()


func _atualizar_estado_botao() -> void:
	disabled = false
	
	var valor_meu_tipo = customizacao_personagem.estilos_em_edicao.get(tipo_estilo, "")
	if valor_meu_tipo == nome_estilo:
		disabled = true
		
	if nome_estilo != "Nenhum":
		if tipo_estilo == "Detalhe1":
			var valor_outro = customizacao_personagem.estilos_em_edicao.get("Detalhe2", "")
			if valor_outro == nome_estilo:
				disabled = true
		elif tipo_estilo == "Detalhe2":
			var valor_outro = customizacao_personagem.estilos_em_edicao.get("Detalhe1", "")
			if valor_outro == nome_estilo:
				disabled = true


func _instanciar_cena(scene: PackedScene) -> Node3D:
	var novo_estilo = scene.instantiate()
	$SubViewportContainer/SubViewport/PreviewEstilo.add_child(novo_estilo)
	return novo_estilo


# para itens que mudam dinamicamente
func _conectar_sinais(tipo: String) -> void:
	if tipo == "Cabelo" or tipo in ["Olhos", "Nariz", "Boca", "Detalhe1", "Detalhe2"]:
		if not customizacao_personagem.preview_alterado.is_connected(_on_preview_alterado):
			customizacao_personagem.preview_alterado.connect(_on_preview_alterado)


func _aplicar_material(malha_3d: MeshInstance3D, nome: String, tipo: String) -> void:
	if not malha_3d.get_surface_override_material(0):
		return
	
	var novo_material = malha_3d.get_surface_override_material(0).duplicate()
	
	if tipo == "Cabelo":
		var cor_atual = customizacao_personagem.estilos_em_edicao.get("Cor Cabelo", Color(0.16, 0.10, 0.06, 1.0))	
		
		if cor_atual is Color:
			novo_material.albedo_color = cor_atual
		elif cor_atual is String and cor_atual != "":
			novo_material.albedo_color = Color(cor_atual)
	
	else:
		textura = estilos.obter_recurso(nome, tipo) as Texture2D
		
		if novo_material is ShaderMaterial:
			if tipo in ["Camisa", "Camiseta", "Calça", "Bermuda", "Casaco", "Calçado"]:
				novo_material.set_shader_parameter("textura_roupa", textura)
			elif tipo == "Olhos":
				novo_material.set_shader_parameter("textura_olhos", textura)
			elif tipo == "Nariz":
				novo_material.set_shader_parameter("textura_nariz", textura)
			elif tipo == "Boca":
				novo_material.set_shader_parameter("textura_boca", textura)
			elif tipo == "Detalhe1":
				novo_material.set_shader_parameter("textura_detalhe_rosto_1", textura)
			elif tipo == "Detalhe2":
				novo_material.set_shader_parameter("textura_detalhe_rosto_2", textura)
		else:
			push_error("O material ", novo_material, "não é um ShaderMaterial")
			
		if tipo == "Brinco":
			camera_preview_estilo.position = Vector3(0.3, 1.4, 0.4)
			camera_preview_estilo.rotation = Vector3(0.0, 0.8, 0.0)
			camera_preview_estilo.fov = 25.0
	
	malha_3d.set_surface_override_material(0, novo_material)


func centraliza_a_camera(novo_estilo, tipo: String):
	if "Brinco" in nome_estilo:
		camera_preview_estilo.position = Vector3(0.3, 1.4, 0.15)
		camera_preview_estilo.rotation = Vector3(0.0, 1.0, 0.0)
		camera_preview_estilo.fov = 25.0
		return

	# posição                    # coord original: (0, 1.332, 1.14)
	match tipo:
		"Camisa", "Casaco":
			camera_preview_estilo.position = Vector3(0.0, 0.2, 0.4)
			camera_preview_estilo.rotation = Vector3(-0.05, 0.0, 0.0)
			camera_preview_estilo.fov = 75.0
		"Camiseta":
			camera_preview_estilo.position = Vector3(0.0, 0.2, 0.35)
			camera_preview_estilo.rotation = Vector3(-0.05, 0.0, 0.0)
			camera_preview_estilo.fov = 75.0
		"Calça":
			camera_preview_estilo.position = Vector3(0.0, 0.4, 1.85)
			camera_preview_estilo.rotation = Vector3(-0.025, 0.0, 0.0)
			camera_preview_estilo.fov = 25.0
		"Bermuda":
			camera_preview_estilo.position = Vector3(0.0, 0.15, 0.35)
			camera_preview_estilo.rotation = Vector3(-0.0, 0.0, 0.0)
			camera_preview_estilo.fov = 75.0
		"Calçado":
			camera_preview_estilo.position = Vector3(0.0, 0.05, 0.80)
			camera_preview_estilo.rotation = Vector3(0.05, 0.0, 0.0)
			camera_preview_estilo.fov = 35.0
		
		"Olhos", "Boca", "Nariz", "Detalhe1", "Detalhe2", "Cabelo":
			camera_preview_estilo.position = Vector3(0.0, 1.4, 0.8) 
			camera_preview_estilo.rotation = Vector3(0.0, 0.0, 0.0)
			camera_preview_estilo.fov = 30.0


func get_nodo_malha(nodo_root: Node) -> MeshInstance3D:
	if nodo_root is MeshInstance3D:
		return nodo_root
	
	for filho in nodo_root.get_children():
		var malha = get_nodo_malha(filho)
		if malha:
			return malha
			
	return null


func _on_preview_alterado(categoria: String, valor: Variant) -> void:
	if categoria == "Cor Cabelo" and tipo_estilo == "Cabelo" and is_instance_valid(estilo_instanciado):
		var malha_3d: MeshInstance3D = get_nodo_malha(estilo_instanciado)
		if malha_3d and malha_3d.get_surface_override_material(0):
			var material = malha_3d.get_surface_override_material(0)
			
			if valor is Color:
				material.albedo_color = valor
			elif valor is String:
				material.albedo_color = Color(valor)
