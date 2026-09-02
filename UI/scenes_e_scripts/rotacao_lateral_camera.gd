
extends Node3D

@export var sensibilidade_rotacao: float = 0.005
@export var sensibilidade_zoom: float = 0.1

@export var sensibilidade_translacao: float = 0.004
@export var limite_translacao_superior: float = 0.5
@export var limite_translacao_inferior: float = -0.5

@export var zoom_minimo: float = 2.0
@export var zoom_maximo: float = 1.25

@onready var camera: Camera3D = $Camera3D2
@onready var target: Node3D = $Personagem

var offset_vertical_atual: float = 0.0
var posicao_mouse_inicial: Vector2 = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("rotacao_horizontal_camera") or event.is_action_pressed("translacao_vertical_camera"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			posicao_mouse_inicial = get_viewport().get_mouse_position()
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	elif event.is_action_released("rotacao_horizontal_camera") or event.is_action_released("translacao_vertical_camera"):
		if not Input.is_action_pressed("rotacao_horizontal_camera") and not Input.is_action_pressed("translacao_vertical_camera"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_viewport().warp_mouse(posicao_mouse_inicial)
			
	if Input.is_action_pressed("rotacao_horizontal_camera") and event is InputEventMouseMotion:
		var angulo = -event.relative.x * sensibilidade_rotacao
		var distancia = camera.position - target.position
		camera.position = target.position + distancia.rotated(Vector3.UP, angulo)
		camera.global_transform.basis = camera.global_transform.basis.rotated(Vector3.UP, angulo)
		
	elif Input.is_action_pressed("translacao_vertical_camera") and event is InputEventMouseMotion:
		var movimento = event.relative.y * sensibilidade_translacao
		var novo_offset = clamp(offset_vertical_atual + movimento, limite_translacao_inferior, limite_translacao_superior)
		var movimento_real = novo_offset - offset_vertical_atual
		offset_vertical_atual = novo_offset
		camera.position += camera.global_transform.basis.y * movimento_real
		
	elif event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
		var direcao_zoom = 0.0
		
		if event.is_action_pressed("zoom_in"):
			direcao_zoom = -sensibilidade_zoom
		elif event.is_action_pressed("zoom_out"):
			direcao_zoom = sensibilidade_zoom
			
		var alvo_atual = target.position + (camera.global_transform.basis.y * offset_vertical_atual)
		var distancia_atual = camera.position.distance_to(alvo_atual)
		var nova_distancia = clamp(distancia_atual + direcao_zoom, zoom_maximo, zoom_minimo)
		var movimento_real = nova_distancia - distancia_atual
		
		camera.position += camera.global_transform.basis.z * movimento_real
