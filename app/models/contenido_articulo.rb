class ContenidoArticulo < ApplicationRecord
  belongs_to :articulo

  validates :costo,     presence: { :message => "El costo del contenido no puede estar vacio." }
  validates :precio,    presence: { :message => "El precio del contenido no puede estar vacio." }
  validates :cantidad,  presence: { :message => "La cantidad del contenido no puede estar vacio." }, numericality: { greater_than: 0, :message => "La cantidad del contendio del articulo debe de ser mayor a 0." }
  validates :medida,    presence: { :message => "La medida del contenido no puede estar vacio." },   uniqueness: { scope: [:articulo_id, :condicion], case_sensitive: false, :message => "El articulo ya tiene registrado esta medida << %{value} >>" }
  validates :condicion, presence: { :message => "La condicion del contenido no puede estar vacio." }


  def self.crear_actualizar_contenido_articulo(params, padre, is_save=false)
    res = Response.new

    contenido                   = ContenidoArticulo.where(:id => params["id"]).first_or_create

    contenido.referencia        = params[:referencia] || nil
    contenido.costo             = params[:costo]
    contenido.precio            = params[:precio]
    contenido.cantidad          = params[:cantidad]
    contenido.medida            = params[:medida]
    contenido.condicion         = params[:condicion]
    contenido.calcular_itbis    = params[:calcular_itbis]

    contenido.valid?

    contenido.errors.delete(:articulo) if !is_save

    if contenido.errors.empty? && (!is_save || (is_save && contenido.save!))
      res.set_data(contenido)
    else
      res.add_msgs(contenido.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.validar_e_inicializar(items, padre)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.crear_actualizar_contenido_articulo(item, padre, !item[:id].nil?)

      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end
    end

    res_valid.set_data array_valid
    return res_valid
  end


end
