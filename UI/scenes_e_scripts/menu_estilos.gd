
extends ScrollContainer

var estilos: Resource = PerfilPersonagem.banco_de_estilos
var lista_estilos: Array[EstiloData]

@export_enum (
	"Camisa", "Camiseta", "Calça", "Bermuda", "Casaco", "Calçado", "Cabelo",
	"Olhos", "Boca", "Nariz", "Detalhe1", "Detalhe2"
	) var tipo_selecionado: String

@onready var cena_mesh_base: PackedScene = preload("uid://lwphiliitg52")
@onready var scene_botao = preload("uid://cu5tt8uouag3e")


func _ready() -> void:
	if tipo_selecionado.is_empty():
		push_error("tipo_selecionado não possui valor atribuído no nó: " + name)
		
	lista_estilos = estilos.obter_lista(tipo_selecionado)
	
	_gerar_botoes(cena_mesh_base)


func cria_os_botoes(scene_mesh: PackedScene):
	for estilo in lista_estilos:
		var nome_estilo = estilo.id
		var novo_botao = scene_botao.instantiate()
		novo_botao.name = nome_estilo
		$ListaBotoes.add_child(novo_botao)
		
		novo_botao.cria_o_estilo(nome_estilo, tipo_selecionado, scene_mesh)


func _gerar_botoes(scene_mesh_base: PackedScene) -> void:
	if tipo_selecionado in ["Casaco", "Cabelo", "Detalhe1", "Detalhe2"]:
		var botao_nenhum = scene_botao.instantiate()
		botao_nenhum.name = "Nenhum"
		$ListaBotoes.add_child(botao_nenhum)
		botao_nenhum.cria_o_estilo("Nenhum", tipo_selecionado, null)
		
	for estilo in lista_estilos:
		var nome_estilo = estilo.id
		var novo_botao = scene_botao.instantiate()
		novo_botao.name = nome_estilo
		$ListaBotoes.add_child(novo_botao)
		
		var cena_final = scene_mesh_base
		if estilo.packed_scene:
			cena_final = estilo.packed_scene
			
		novo_botao.cria_o_estilo(nome_estilo, tipo_selecionado, cena_final)


# isso é usado pra não scrollar na vertical ao chegar no fim do scroll horizontal
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in") || event.is_action_pressed("zoom_out"):
		var h_bar = get_h_scroll_bar()
		var v_bar = get_v_scroll_bar()
		var bar: ScrollBar = null
		
		if h_bar and h_bar.visible:
			bar = h_bar
		elif v_bar and v_bar.visible:
			bar = v_bar
		
		if bar:
			var diminuindo = event.is_action_pressed("zoom_in")
			var no_limite = false
			
			if diminuindo:
				no_limite = bar.value <= (bar.min_value + 0.1)
			else:
				no_limite = bar.value >= (bar.max_value - bar.page - 0.1)
			
			if no_limite:
				accept_event()
