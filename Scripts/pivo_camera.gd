
extends Node3D

@export var sensibilidade: float = 0.2
@export var distancia: float = 2.5:
	set(valor):
		distancia = clamp(valor, 0.1, 4)
		if camera:
			camera.position.z = distancia
			_define_offset_painel()

@onready var painel_visualizacao: Panel = get_tree().get_first_node_in_group("painel_visualizacao_3d")
@onready var camera: Camera3D = $Camera3D

@onready var coord_objeto_observado: Vector3 = get_tree().get_first_node_in_group("bike").global_position:
	set(valor):
		coord_objeto_observado = valor
		global_position = valor

var is_rotating: bool = false
var offset_painel: float


func _ready() -> void:
	call_deferred("_inicializar_posicao_camera")

func _inicializar_posicao_camera() -> void:
	global_position = coord_objeto_observado
	camera.position = Vector3(0, 0, distancia)
	_define_offset_painel()

func _process(_delta: float) -> void:
	camera.look_at(global_position, Vector3.UP)


func _unhandled_input(event: InputEvent):
	var mouse_pos = get_viewport().get_mouse_position()
	var sobre_painel = false
	
	if painel_visualizacao and painel_visualizacao.is_visible_in_tree():
		sobre_painel = painel_visualizacao.get_global_rect().has_point(mouse_pos)
	
	if not sobre_painel and not is_rotating:
		return
		
	if event.is_action("scroll_up"):
		distancia -= distancia * 0.15
	
	elif event.is_action("scroll_down"):
		distancia += distancia * 0.15
	
	elif event.is_action_pressed("camera_movement"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		is_rotating = true
	
	elif event.is_action_released("camera_movement"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_rotating = false
	
	if event is InputEventMouseMotion and is_rotating:
		rotate_y(deg_to_rad(-event.relative.x * sensibilidade))
		
		var prox_rot_x = rotation.x + deg_to_rad(-event.relative.y * sensibilidade)
		rotation.x = clamp(prox_rot_x, deg_to_rad(-80), deg_to_rad(80))


func _define_offset_painel() -> void:
	if not painel_visualizacao or not painel_visualizacao.is_visible_in_tree():
		if camera:
			camera.h_offset = 0.0
		return
	
	var largura_tela = get_viewport().get_visible_rect().size.x
	var centro_tela = largura_tela / 2.0
	var rect_painel = painel_visualizacao.get_global_rect()
	
	if rect_painel.size.x <= 0:
		return
		
	var centro_painel = rect_painel.position.x + (rect_painel.size.x / 2.0)
	var distancia_pixels = centro_painel - centro_tela
	
	offset_painel = -(distancia_pixels / largura_tela) * (distancia * 2.6)
	
	if camera:
		camera.h_offset = offset_painel
