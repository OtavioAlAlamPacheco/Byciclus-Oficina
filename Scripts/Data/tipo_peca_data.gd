
class_name TipoPecaData
extends Resource

@export var id: String
@export var silhueta_texture: Texture2D

@export var slots_e_materiais: Array[SlotMaterialData] = []

@export_group("Configuracao para os botões")
@export var posicao_camera: Vector3 = Vector3.ZERO
@export var rotacao_camera: Vector3 = Vector3.ZERO
