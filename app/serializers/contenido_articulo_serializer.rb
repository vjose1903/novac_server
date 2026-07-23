class ContenidoArticuloSerializer < ActiveModel::Serializer
  attribute :id,                         if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :articulo_id,                if: Proc.new { self.get_param('articulo_id') || self.get_param('all') }
  attribute :referencia,                 if: Proc.new { self.get_param('referencia') || self.get_param('all') }
  attribute :costo,                      if: Proc.new { self.get_param('costo') || self.get_param('all') }
  attribute :precio,                     if: Proc.new { self.get_param('precio') || self.get_param('all') }
  attribute :cantidad,                   if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
  attribute :medida,                     if: Proc.new { self.get_param('medida') || self.get_param('all') }
  attribute :condicion,                  if: Proc.new { self.get_param('condicion') || self.get_param('all') }
  attribute :calcular_itbis,             if: Proc.new { self.get_param('calcular_itbis') || self.get_param('all') }

  def calcular_itbis
    return false if object.calcular_itbis.nil?

    object.calcular_itbis
  end

  def get_param(col)
    @instance_options[col.to_sym]
  end
end
