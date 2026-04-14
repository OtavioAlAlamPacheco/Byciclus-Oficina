extends Camera3D

@export var sensibilidade_movimento: float = 0.8
@export var distancia_da_bike: float = 2.5

@onready var painel_visualizacao: Panel = get_tree().get_first_node_in_group("painel_visualizacao_3d")

@onready var coord_objeto_observado: Vector3 = get_tree().get_first_node_in_group("bike").global_position:
	set(valor):
		coord_objeto_observado = valor
		_movimenta_a_camera()

var peca_selecionada
var is_rotating: bool = false
var mouse_delta: Vector2 = Vector2.ZERO
var offset_painel: float

func _ready() -> void:
	await get_tree().process_frame
	_define_offset_painel()
	
	_movimenta_a_camera()
	look_at(coord_objeto_observado)


func _process(_delta: float) -> void:
	if is_rotating:
		_movimenta_a_camera()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("camera_movement"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		is_rotating = true
	elif event.is_action_released("camera_movement"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_rotating = false
	
	if event is InputEventMouseMotion and is_rotating:
		mouse_delta += event.relative

func _movimenta_a_camera():
	var offset_rotacao = _define_offset_rotacao_camera()
	
	global_position = coord_objeto_observado + offset_rotacao
	#look_at(coord_objeto_observado, Vector3.UP)
	self.h_offset = offset_painel


# offset para orbitar a bike
func _define_offset_rotacao_camera() -> Vector3:
	var angulo_y = deg_to_rad(-mouse_delta.x * sensibilidade_movimento)
	var angulo_x = deg_to_rad(-mouse_delta.y * sensibilidade_movimento)
	
	if is_rotating:
		mouse_delta = Vector2.ZERO
	
	var vetor_direcao = (global_position - coord_objeto_observado).normalized() * distancia_da_bike
	
	var offset_final
	var offset_horizontal = vetor_direcao.rotated(Vector3.UP, angulo_y)
	var offset_vertical = offset_horizontal.rotated(transform.basis.x, angulo_x)
	
	var dot_product = offset_vertical.normalized().dot(Vector3.UP)
	
	if abs(dot_product) < 0.98:
		offset_final = offset_vertical
	else:
		offset_final = offset_horizontal
	
	return offset_final


# offset para a bike ficar centralizada no painel de visualização
func _define_offset_painel() -> void:
	if not painel_visualizacao or not painel_visualizacao.is_visible_in_tree():
		offset_painel = 0.0
		return
	
	var largura_tela = get_viewport().get_visible_rect().size.x
	var centro_tela = largura_tela / 2.0
	
	var rect_painel = painel_visualizacao.get_global_rect()
	if rect_painel.size.x <= 0:
		return 
		
	var centro_painel = rect_painel.position.x + (rect_painel.size.x / 2.0)
	var distancia_pixels = centro_painel - centro_tela
	
	offset_painel = -(distancia_pixels / largura_tela) * 7.0


func _unhandled_key_input(event: InputEvent) -> void:
	
	# SEGUIR MEXENDO AQUI. Essa função é só pra teste
	
	if event.is_action_pressed("teste2"):
		print("x")
		coord_objeto_observado += Vector3(1, 1, 1)
