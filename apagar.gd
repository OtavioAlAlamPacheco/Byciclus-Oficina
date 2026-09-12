
extends Node3D

@onready var personagem_1: Node3D = $"Personagem 1"
@onready var personagem_2: Node3D = $"Personagem 2"
@onready var personagem_3: Node3D = $"Personagem 3"

@onready var personagem = personagem_1

func _unhandled_key_input(event: InputEvent) -> void:
	
	# pra escolher qual personagem afetar, usa as teclas de 1 a 3
	
	if event.is_action_pressed("debug_1"): # apertar a tecla 1
		personagem = personagem_1
	
	elif event.is_action_pressed("debug_2"): # apertar a tecla 2
		personagem = personagem_2 
	
	elif event.is_action_pressed("debug_3"): # apertar a tecla 3
		personagem = personagem_3
	
	
	# pra ativar animação no personagem selecionado, usa space
	
	if event.is_action_pressed("debug_space"): # apertar a tecla space
		print("\nPressionou o debug. Personagem selecionado: ", personagem.name)
		print("Ativando a animação: ")
		personagem.tocar_animacao("Caminhar", true)


# o visual do personagem é carregado automaticamente ao mudar o id_personagem
# dele. Usa o LineEdit pra testar:

func _on_line_edit_text_submitted(novo_id: String) -> void:
	# para carregar o personagem do jogador, o id_personagem deve ser "jogador".
	# para personagem NPC, tem que colocar o nome do NPC que quer carregar.

	# (eu criei dois NPCs chamados "NPC 1" e "NPC 2", mas não sei se é enviado 
	# no GitHub. Talvez precise criar NPCs se quiser testar)
	personagem.id_personagem = novo_id
