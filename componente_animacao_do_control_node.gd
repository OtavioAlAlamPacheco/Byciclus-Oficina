
extends Node
class_name ComponnteAnimacaoBotoes

var tween: Tween
var control_node: Control
var escala_original: Vector2

func _ready() -> void:
	control_node = get_parent() as Control
	
	if not control_node:
		push_warning("O pai do AnimadorBotao deve ser um Control")
		return
		
	escala_original = control_node.scale
	
	control_node.resized.connect(_atualizar_pivo)
	_atualizar_pivo()
	
	if control_node.has_signal("mouse_entered"):
		control_node.mouse_entered.connect(_ao_entrar_mouse)
	if control_node.has_signal("mouse_exited"):
		control_node.mouse_exited.connect(_ao_sair_mouse)
	if control_node.has_signal("button_down"):
		control_node.button_down.connect(_ao_pressionar)
	if control_node.has_signal("button_up"):
		control_node.button_up.connect(_ao_soltar)


func _atualizar_pivo() -> void:
	if is_instance_valid(control_node):
		control_node.pivot_offset = control_node.size / 2.0


func _ao_entrar_mouse() -> void:
	_animar_botao(0.95)


func _ao_sair_mouse() -> void:
	_animar_botao(1.0)
	
	
func _ao_pressionar() -> void:
	_animar_botao(0.85)


func _ao_soltar() -> void:
	if control_node.is_hovered():
		_animar_botao(0.95)
	else:
		_animar_botao(1.0)


func _animar_botao(multiplicador_escala: float) -> void:
	if tween and tween.is_running():
		tween.kill()
	
	control_node.pivot_offset = control_node.size / 2.0
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	var escala_alvo = escala_original * multiplicador_escala
	
	tween.tween_property(control_node, "scale", escala_alvo, 0.2)
