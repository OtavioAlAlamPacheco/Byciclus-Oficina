


# eu estava querendo adicionar um sistema de idle animation, mas
# percebi que a animação principal (balnçar braços) estava fazendo
# movimento demais no personagem, o que dificulta a visualização
# das partes customizadas. No fim, fiz o personagem ficar em
# T-Pose, mesmo

extends Timer

@export var tempo_minimo: int = 12
@export var tempo_maximo: int = 24

signal tocar_animacao(nome: String)

var animacoes: Array = [
	"Caminhar",
	"Correr", # essa animação tá estranha. É o antigo caminhar
	"Idle balançar braços",
	"Idle coçar cabeça (direita)",
	"Idle coçar cabeça (esquerda)",
	"Levantar",
	"Sentar",
]

var animacoes_idle: Array = [
	"Idle balançar braços",
	["Idle coçar cabeça (direita)", "Idle coçar cabeça (esquerda)"],
]

func _on_timeout() -> void:
	var nome_anim = _seleciona_uma_idle()
	tocar_animacao

func _seleciona_uma_idle() -> String:
	var animacao = animacoes_idle.pick_random()
	if animacao is Array:
		return animacao.pick_random()
	else:
		return animacao

func _novo_wait_time_para_idle():
	wait_time = randi_range(tempo_minimo, tempo_maximo)
