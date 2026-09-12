
extends Button

const THEME_BOTAO_NAO_SELECIONADO = preload("uid://xtha0ihy5e14")
const THEME_BOTAO_SELECIONADO = preload("uid://drfnkf2566lvj")

@export_enum("Visualizar bicicleta", "Visualizar peça") var modo_do_botao: String

@onready var pivo_camera: Node3D = %PivoCamera
@onready var menu_variacao: Panel = %MenuSelecaoVariacaoPeca
@onready var bike: Node3D = get_tree().get_first_node_in_group("bike")
@onready var oficina: Node = get_tree().get_first_node_in_group("oficina")


func _on_pressed() -> void:
	if not oficina or oficina.modo_visualizacao == modo_do_botao:
		return
	
	oficina.alterar_modo_visualizacao(modo_do_botao)
	
	if oficina.modo_visualizacao == "Visualizar bicicleta":
		pivo_camera.coord_objeto_observado = bike.global_position
	else:
		_definir_novo_objeto_observado()


func _on_tipo_foi_selecionado(_id: String):
	if oficina and oficina.modo_visualizacao == "Visualizar peça":
		_definir_novo_objeto_observado()


func _definir_novo_objeto_observado():
	var id_variacao = menu_variacao.id_variacao_selecionada
	var coord = bike.obter_coordenada_da_peca(id_variacao)
	
	if coord != null:
		pivo_camera.coord_objeto_observado = coord
