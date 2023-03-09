class PeriodoFiscalSerializer < ActiveModel::Serializer
  attribute :id
  attribute :fecha_inicio
  attribute :fecha_cierre
  attribute :estado
  attribute :detalles_periodos_fiscales

	def detalles_periodos_fiscales
		serialize_parser(object.detalles_periodos_fiscales, {all: true})
	end

end
