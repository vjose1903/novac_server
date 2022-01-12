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

  def precio
    puts " ============== "
    puts object.precio
    puts " ============== "

    object.precio
  end

  def calcular_itbis
    object.calcular_itbis || false
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
