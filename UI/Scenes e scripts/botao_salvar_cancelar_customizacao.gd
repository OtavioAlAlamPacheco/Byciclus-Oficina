
extends Button

@onready var customizacao_personagem: Control = get_tree().get_first_node_in_group("customizacao_personagem")

func _on_confirm_pressed() -> void:
	customizacao_personagem.confirmar_alteracoes()

func _on_cancel_pressed() -> void:
	get_tree().quit()
