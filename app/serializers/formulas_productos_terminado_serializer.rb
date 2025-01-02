class FormulasProductosTerminadoSerializer < ActiveModel::Serializer
  attribute :id,                        if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :articulo_id,               if: Proc.new { self.get_param('articulo_id') || self.get_param('all') }
  attribute :cantidad,                  if: Proc.new { self.get_param('cantidad') || self.get_param('all') }
  attribute :costo,                     if: Proc.new { self.get_param('costo') || self.get_param('all') }
  attribute :precio,                    if: Proc.new { self.get_param('precio') || self.get_param('all') }
  attribute :medida,                    if: Proc.new { self.get_param('medida') || self.get_param('all') }
  attribute :articulo_combo_id,         if: Proc.new { self.get_param('articulo_combo_id')    || self.get_param('all') }

  attribute :articulo_combo,            if: Proc.new { self.get_param('articulo_combo') || self.get_param('all') }
  attribute :nombre,                    if: Proc.new { self.get_param('nombre') || self.get_param('all') }
  attribute :existencia,                if: Proc.new { self.get_param('existencia') || self.get_param('all') }
  attribute :contenido,                 if: Proc.new { self.get_param('contenido') || self.get_param('all') }

  def articulo_combo
    begin
      @articulo_combo = object.articulo_combo
    rescue
      @articulo_combo = Articulo.find_by_id(object.articulo_combo_id)
    end

    @articulo_combo
  end

  def nombre
    @articulo_combo.nombre
  end

  def existencia
    object.articulo_combo.calcularCantidades
  end

  def contenido
    object.articulo_combo.calcularContenidos(true)
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
