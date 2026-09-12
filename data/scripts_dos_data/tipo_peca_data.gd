
class_name TipoPecaData
extends Resource

@export var id: String
@export var silhueta_texture: Texture2D

@export var slots_e_materiais: Array[SlotMaterialData] = []

@export_group("Configuração para os botões")
@export var posicao_camera: Vector3 = Vector3.ZERO
@export var rotacao_camera: Vector3 = Vector3.ZERO

@export_group("Sincronização")
@export var tipo_sincronizado: TipoPecaData
@export var sincronizar_material_com_tipo: TipoPecaData
@export var offset_de_slot_sincronizado: int = 0
