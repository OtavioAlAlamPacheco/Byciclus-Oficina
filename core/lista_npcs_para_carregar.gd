
extends HBoxContainer

@onready var option_button: OptionButton = $OptionButton
@onready var customizacao_personagem = get_tree().get_first_node_in_group("customizacao_personagem")

func _ready() -> void:
	if customizacao_personagem.tipo != "NPC":
		hide()
	else:
		option_button.clear()
		option_button.add_item("Selecione um NPC...")
		option_button.set_item_disabled(0, true)
		
		var nomes = PerfilPersonagem.obter_nomes_npcs_salvos()
		for nome in nomes:
			option_button.add_item(nome)
			
		option_button.select(-1)
		
		if not option_button.item_selected.is_connected(customizacao_personagem._on_npc_selecionado):
			option_button.item_selected.connect(customizacao_personagem._on_npc_selecionado)
