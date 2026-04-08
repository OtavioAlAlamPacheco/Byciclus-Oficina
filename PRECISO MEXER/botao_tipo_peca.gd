
@tool
extends botao_peca

@export_enum (
		"Alavanca", "Cambio traseiro", "Catraca frontal", "Catraca traseira",
		"Corrente", "Freio", "Garfo", "Guidao", "Pedal", "Pedivela", "Roda",
		"Quadro", "Selim"
	) var tipo_do_botao: String = "Quadro"

static var tipo_selecionado: String = "Quadro"

func _on_pressed() -> void:
	tipo_selecionado = tipo_do_botao
	print("BOTÃO PRESSIONADO. TIPO_SELECIONADO: ", tipo_selecionado)
	
	var nodo_oficina = get_tree().current_scene
	if nodo_oficina and nodo_oficina.has_signal("tipo_foi_selecionado"):
		nodo_oficina.tipo_foi_selecionado.emit(tipo_do_botao)
