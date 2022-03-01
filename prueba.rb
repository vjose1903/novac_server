module Types
  class PantallaSectorType < Types::BaseObject
    field :id, Integer, null: false
    field :sector_area_id, Integer, null: false
    field :pantalla_id, Integer, null: false
    field :height, Float, null: false
    field :width, Float, null: false
    field :activo, Boolean, null: true
    field :columnas, Integer, null: false
    field :filas, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

		aqui esta el patron buscado

		## =============================
		# BELONGS_TO
		## =============================
		field :pantalla, Types::PantallaType, null: false
		field :sector_area, Types::SectorAreaType, null: false end
end
