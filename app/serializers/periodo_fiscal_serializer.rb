class PeriodoFiscalSerializer < ActiveModel::Serializer
  attribute :id,
	attribute :fecha_inicio,
	attribute :fecha_cierre,
	attribute :estado
end
