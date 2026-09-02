
extends Button

@onready var customizacao_bike: Control = get_tree().get_first_node_in_group("oficina")

func _on_confirm_pressed() -> void:
	customizacao_bike.confirmar_alteracoes()

func _on_cancel_pressed() -> void:
	get_tree().quit()
