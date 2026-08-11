extends Button

@export_enum("Visualizar bicicleta", "Visualizar peça") var modo_do_botao: String

@export var pivo_camera: Node3D
@export var menu_variacao: Panel
@onready var bike: Node3D = get_tree().get_first_node_in_group("bike")
@onready var oficina: Node = get_tree().get_first_node_in_group("oficina")	# AQUI (Problema 4)


func _on_pressed() -> void:
	if not oficina or oficina.modo_visualizacao == modo_do_botao:	# AQUI (Problema 4)
		return
	
	oficina.alterar_modo_visualizacao(modo_do_botao)	# AQUI (Problema 4)
	
	if oficina.modo_visualizacao == "Visualizar bicicleta":	# AQUI (Problema 4)
		print("\n\nEstá no modo de visualização de bike. Observando a coord", bike.global_position)
		pivo_camera.coord_objeto_observado = bike.global_position
	else:
		_definir_novo_objeto_observado()	# AQUI (Problema 5 - For loop removido)


func _on_tipo_foi_selecionado(_id: String):
	if oficina and oficina.modo_visualizacao == "Visualizar peça":	# AQUI (Problema 4)
		_definir_novo_objeto_observado()


func _atualizar_painel(modo_atual: String):	# AQUI (Problema 4)
	var painel = $"../"
	var style_box = painel.get_theme_stylebox("panel").duplicate()
	
	if modo_do_botao == modo_atual:	# AQUI (Problema 4)
		style_box.bg_color = Color("d8dab8")
		painel.add_theme_stylebox_override("panel", style_box)
	else:
		style_box.bg_color = Color("eed0b8")
		painel.add_theme_stylebox_override("panel", style_box)


func _definir_novo_objeto_observado():
	var id_variacao = menu_variacao.id_variacao_selecionada
	var coord = bike.obter_coordenada_da_peca(id_variacao)	# AQUI (Problema 5)
	
	if coord != null:	# AQUI (Problema 5)
		pivo_camera.coord_objeto_observado = coord	# AQUI (Problema 5)
