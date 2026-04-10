
@tool
extends Button

@export var resource_variacao: VariacaoPecaData

# vai acessar as variações de peça usando o CatalogoPecas.
# Penso em duas formas de fazer esse menu:
	# a) Cria um menu pra cada tipo de peça, mostrando de forma estática
	#    as variações disponíveis
	# b) Usa script pra criar o menu
	#		-> vou usar o b. É o "menu_dinamico", mas ainda não trabalhei nele

# signal pra fazer a peça ser instanciada

func _ready() -> void:
	if resource_variacao and resource_variacao.render_texture:
		var novo_style = StyleBoxTexture.new()
		novo_style.texture = resource_variacao.render_texture
		
		add_theme_stylebox_override("normal", novo_style)
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_pressed() -> void:
	print("\nApertou o botão de seleção de variação.")
	print("Resource_variacao: ", resource_variacao)
	
	var nodo_oficina = get_tree().current_scene
	if nodo_oficina and nodo_oficina.has_signal("variacao_foi_selecionada"):
		nodo_oficina.variacao_foi_selecionada.emit(resource_variacao.id)
