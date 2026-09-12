
extends TextureRect

@onready var cursor: Panel = $Cursor
@onready var customizacao_personagem: Control = get_tree().get_first_node_in_group("customizacao_personagem")

func _ready() -> void:
	cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	customizacao_personagem.perfil_carregado.connect(_sincronizar_cor)
	customizacao_personagem.preview_alterado.connect(_on_preview_alterado_local)


func _sincronizar_cor(aparencia: Dictionary) -> void:
	if aparencia.has("Cor Pele"):
		var cor_salva = aparencia["Cor Pele"]
		if cor_salva is Color:
			_posicionar_cursor_pela_cor(cor_salva)
		elif cor_salva is String and cor_salva != "":
			_posicionar_cursor_pela_cor(Color(cor_salva))


func _on_preview_alterado_local(categoria: String, valor: Variant) -> void:
	if categoria == "Cor Pele":
		if valor is Color:
			_posicionar_cursor_pela_cor(valor)


func _gui_input(event: InputEvent) -> void:
	# clique do mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_atualizar_cor(event.position)
	# movimento do mouse
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		_atualizar_cor(event.position)


func _atualizar_cor(posicao_mouse: Vector2) -> void:
	var clipping = posicao_mouse.clamp(Vector2.ZERO, size)
	
	if cursor:
		cursor.position = clipping - (cursor.size / 2.0)
	
	var imagem = texture.get_image()
	var uv = clipping / size
	var pixel_x = int(uv.x * imagem.get_width())
	var pixel_y = int(uv.y * imagem.get_height())
	pixel_x = clamp(pixel_x, 0, imagem.get_width() - 1)
	pixel_y = clamp(pixel_y, 0, imagem.get_height() - 1)
	
	var cor_final = imagem.get_pixel(pixel_x, pixel_y)
	customizacao_personagem.selecionar_estilo_local("Cor Pele", cor_final)


func _posicionar_cursor_pela_cor(cor_alvo: Color) -> void:
	var imagem = texture.get_image()
	var melhor_pos = Vector2.ZERO
	var menor_distancia = 100.0
	
	for x in range(imagem.get_width()):
		for y in range(imagem.get_height()):
			var cor_pixel = imagem.get_pixel(x, y)
			var dist_r = cor_alvo.r - cor_pixel.r
			var dist_g = cor_alvo.g - cor_pixel.g
			var dist_b = cor_alvo.b - cor_pixel.b
			var distancia = (dist_r * dist_r) + (dist_g * dist_g) + (dist_b * dist_b)
			if distancia < menor_distancia:
				menor_distancia = distancia
				melhor_pos = Vector2(x, y)
	
	var proporcao_x = melhor_pos.x / float(imagem.get_width())
	var proporcao_y = 0.5
	
	var tamanho_original = cursor.size
	
	cursor.anchor_left = proporcao_x
	cursor.anchor_right = proporcao_x
	cursor.anchor_top = proporcao_y
	cursor.anchor_bottom = proporcao_y
	
	cursor.offset_left = -tamanho_original.x / 2.0
	cursor.offset_top = -tamanho_original.y / 2.0
	cursor.offset_right = tamanho_original.x / 2.0
	cursor.offset_bottom = tamanho_original.y / 2.0
