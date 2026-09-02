
extends Resource
class_name BancoDeEstilos

@export var camisas: Array[EstiloData] = []
@export var camisetas: Array[EstiloData] = []
@export var calcas: Array[EstiloData] = []
@export var bermudas: Array[EstiloData] = []
@export var casacos: Array[EstiloData] = []
@export var calcados: Array[EstiloData] = []

@export var cabelos: Array[EstiloData] = []

@export var bocas: Array[EstiloData] = []
@export var narizes: Array[EstiloData] = []
@export var olhos: Array[EstiloData] = []
@export var detalhes: Array[EstiloData] = []

@export var mascaras_por_tipo: Dictionary[String, Texture2D] = {}


func obter_recurso(nome: String, tipo: String) -> Resource:
	var lista = obter_lista(tipo)
	for estilo in lista:
		if estilo and estilo.id == nome:
			if estilo.textura:
				return estilo.textura
			elif estilo.packed_scene:
				return estilo.packed_scene
	return null


func obter_lista(tipo: String) -> Array[EstiloData]:	
	match tipo:
		"Camisa": return camisas
		"Camiseta": return camisetas
		"Calça": return calcas
		"Bermuda": return bermudas
		"Casaco": return casacos
		"Calçado": return calcados
		"Cabelo": return cabelos
		"Boca": return bocas
		"Nariz": return narizes
		"Olhos": return olhos
		"Detalhe1", "Detalhe2": return detalhes
		_: return []
