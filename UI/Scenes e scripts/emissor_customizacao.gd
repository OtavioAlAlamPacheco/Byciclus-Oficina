
extends Control

const THEME_BOTAO_NAO_SELECIONADO = preload("uid://xtha0ihy5e14")
const THEME_BOTAO_SELECIONADO = preload("uid://drfnkf2566lvj")

@onready var customizacao_personagem: Control = get_tree().get_first_node_in_group("customizacao_personagem")

@export_enum(
	"Tipo de personagem", "Nome Personagem", "Genero", "Cor Cabelo", "Robustez",
	"Formato do queixo", "Profundidade do nariz", "Tamanho da orelha"
) var categoria: String

@export_enum(
	"Nada" ,"Masculino", "Feminino", "Jogador", "NPC"
) var param_extra: String = "Nada"


func _ready() -> void:
	var deve_esconder = false
	if categoria == "Tipo de personagem":
		deve_esconder = true
	elif param_extra == "Jogador" or param_extra == "NPC":
		deve_esconder = true
		
	if deve_esconder and not OS.has_feature("editor"):
		hide()
	
	customizacao_personagem.perfil_carregado.connect(_sincronizar_valor)
	customizacao_personagem.preview_alterado.connect(_on_preview_alterado_local)


func _sincronizar_valor(aparencia: Dictionary) -> void:
	if categoria == "Tipo de personagem":
		_aplicar_valor_na_interface(customizacao_personagem.tipo)
		return
	
	if aparencia.has(categoria):
		var valor_salvo = aparencia[categoria]
		_aplicar_valor_na_interface(valor_salvo)
	else:
		if "button_pressed" in self:
			_on_value_changed(self.button_pressed)
		elif "value" in self:
			_on_value_changed(self.value)
		elif "color" in self:
			_on_value_changed(self.color)
		elif "text" in self:
			_on_value_changed(self.text)


func _on_preview_alterado_local(cat: String, val: Variant) -> void:
	if cat == categoria:
		_aplicar_valor_na_interface(val)


func _aplicar_valor_na_interface(valor_salvo: Variant) -> void:
	set_block_signals(true)
	
	if "button_pressed" in self:
		var deve_pressionar = false
		if param_extra == str(valor_salvo):
			deve_pressionar = true
			
		if self.button_pressed != deve_pressionar:
			self.button_pressed = deve_pressionar
			
		if categoria in ["Tipo de personagem", "Genero"]:
			if deve_pressionar:
				self.theme = THEME_BOTAO_SELECIONADO
			else:
				self.theme = THEME_BOTAO_NAO_SELECIONADO
				
	elif "value" in self:
		if self.value != float(valor_salvo):
			self.value = float(valor_salvo)
	elif "color" in self:
		var cor_salva = valor_salvo if valor_salvo is Color else Color(valor_salvo)
		if self.color != cor_salva:
			self.color = cor_salva
	elif "text" in self:
		if self.text != str(valor_salvo):
			self.text = str(valor_salvo)
	
	set_block_signals(false)


func _on_value_changed(value: Variant) -> void:
	if typeof(value) == TYPE_BOOL and value == false:
		return
		
	if categoria == "Genero" and param_extra in ["Masculino", "Feminino"]:
		customizacao_personagem.selecionar_estilo_local(categoria, param_extra)
	elif categoria == "Tipo de personagem" and param_extra in ["Jogador", "NPC"]:
		customizacao_personagem.definir_tipo_personagem(param_extra)
	else:
		customizacao_personagem.selecionar_estilo_local(categoria, value)
