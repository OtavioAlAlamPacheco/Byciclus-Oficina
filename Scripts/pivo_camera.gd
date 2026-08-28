
extends Node3D

@export var sensibilidade: float = 0.3
@export var distancia: float = 1.7:
	set(valor):
		distancia = clamp(valor, 0.2, 2.0)
		if camera:
			camera.position.z = distancia

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

func _process(_delta: float) -> void:
	camera.look_at(global_position, Vector3.UP)


func _unhandled_input(event: InputEvent):
	var mouse_pos = get_viewport().get_mouse_position()
	var sobre_painel = false
	
	if get_viewport() is SubViewport:
		var viewport_rect = Rect2(Vector2.ZERO, get_viewport().size)
		sobre_painel = viewport_rect.has_point(mouse_pos)
	
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


func focar_em_nodo(nodo: Node3D) -> void:
	var malhas = nodo.find_children("*", "VisualInstance3D", true, false)
	
	# se não tiver malha, volta pro comportamento padrão
	if malhas.is_empty():
		coord_objeto_observado = nodo.global_position
		return
		
	var min_global = Vector3(INF, INF, INF)
	var max_global = Vector3(-INF, -INF, -INF)
	
	for malha in malhas:
		var aabb = malha.get_aabb()
		
		for i in range(8):
			var vertice_local = aabb.get_endpoint(i)
			var vertice_global = malha.global_transform * vertice_local
			
			min_global = min_global.min(vertice_global)
			max_global = max_global.max(vertice_global)
			
	var centro_real = (min_global + max_global) / 2.0
	
	coord_objeto_observado = centro_real
