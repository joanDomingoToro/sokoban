extends Node2D

enum TileType {
	VACIO = 0,
	HIERBA = 1,
	PARED = 2,
	AGUA = 3
}

var mapa_ids: Array = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 2, 2, 2, 2, 0],
	[0, 2, 2, 2, 2, 2, 1, 3, 2, 0],
	[0, 2, 1, 1, 1, 1, 1, 3, 2, 0],
	[0, 2, 1, 1, 1, 2, 1, 1, 2, 0],
	[0, 2, 2, 2, 2, 2, 2, 2, 2, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

var coords_atlas: Dictionary = {
	TileType.HIERBA: Vector2i(0,1),
	TileType.PARED: Vector2i(1, 0),
	TileType.AGUA: Vector2i(1,1)
}

var tile_map_layer: TileMapLayer

func _ready() -> void:
	tile_map_layer = TileMapLayer.new()
	add_child(tile_map_layer)
	tile_map_layer.position = Vector2(180, 200)
	
	# 1. Configurar TileSet a 128x128
	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(128, 128)
	tile_set.add_physics_layer()
	
	var texture = load("res://Sokoba.png")
	if not texture:
		print("ERROR: No se encuentra la textura 'res://mi_atlas.png'")
		return

	# 2. Configurar el tamaño de la región del atlas a 128x128
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(128, 128)
	
	# 3. Crear tiles y colisiones ajustadas a 128x128
	for tile_type in coords_atlas.keys():
		var coord = coords_atlas[tile_type]
		atlas_source.create_tile(coord)
		
		var tile_data = atlas_source.get_tile_data(coord, 0)
		configurar_colision(tile_data, tile_type)
	
	var source_id = tile_set.add_source(atlas_source)
	tile_map_layer.tile_set = tile_set
	
	generar_mapa_desde_matriz(source_id)

func configurar_colision(tile_data: TileData, tipo: TileType) -> void:
	match tipo:
		TileType.HIERBA:
			pass
			
		TileType.PARED:
			# Colisión completa de 128x128 (de -64 a 64)
			var poligono_completo = PackedVector2Array([
				Vector2(-64, -64), Vector2(64, -64),
				Vector2(64, 64), Vector2(-64, 64)
			])
			tile_data.add_collision_polygon(0)
			tile_data.set_collision_polygon_points(0, 0, poligono_completo)
			
		TileType.AGUA:
			# Colisión parcial / reducida (cuadrado central de 64x64)
			var poligono_centro = PackedVector2Array([
				Vector2(-32, -32), Vector2(32, -32),
				Vector2(32, 32), Vector2(-32, 32)
			])
			tile_data.add_collision_polygon(0)
			tile_data.set_collision_polygon_points(0, 0, poligono_centro)

func generar_mapa_desde_matriz(source_id: int) -> void:
	for y in range(mapa_ids.size()):
		for x in range(mapa_ids[y].size()):
			var tile_id = mapa_ids[y][x]
			if tile_id != TileType.VACIO and coords_atlas.has(tile_id):
				var atlas_coord = coords_atlas[tile_id]
				tile_map_layer.set_cell(Vector2i(x, y), source_id, atlas_coord)