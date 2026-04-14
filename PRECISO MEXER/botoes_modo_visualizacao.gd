extends Button

@export_enum("Visualizar bicicleta", "Visualizar peça") var modo_do_botao: String

@onready var camera_3d: Camera3D = $"../../../../../../../Camera3D"
@onready var bike: Node3D = $"../../../../../../../Bike"
@onready var menu_variacao: Panel = $"../../../MenuSelecaoVariacaoPeca"

static var modo_visualizacao: String = "Visualizar bicicleta"

func _on_pressed() -> void:
	modo_visualizacao = modo_do_botao
	
	if modo_visualizacao == "Visualizar bicicleta":
		print("\n\nEstá no modo de visualização de bike. Observando a coord", bike.global_position)
		camera_3d.coord_objeto_observado = bike.global_position
	else:
		var id_variacao = menu_variacao.id_variacao_selecionada
		for instancia in bike.pecas_instanciadas:
			if id_variacao == instancia.resource_variacao["id"]:
				
				# SEGUIR MEXENDO AQUI
				
				print("b")
				print("instancia: ", instancia.instancia)
				
				var coord = instancia.instancia.global_position
				print("instancia.instancia.global_position: ", coord)
				camera_3d.coord_objeto_observado = coord
				return
