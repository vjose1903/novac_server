class CategoriaEntidadContable < ApplicationRecord
	self.table_name = "categorias_entidades_contables"

  belongs_to :cuenta_contable_control,      class_name: 'CuentaContable', optional: false
  belongs_to :cuenta_contable_auxiliar,     class_name: 'CuentaContable', optional: true
  belongs_to :configuracion_entidad_cuenta

  has_many   :entidad_cuentas_contables, :as => :origen_categoria, dependent: :destroy, class_name: 'EntidadCuentaContable'

  validates :descripcion,                presence: { :message => "Descripción de la categoria no puede estar vacia." },         uniqueness: { scope:[ :configuracion_entidad_cuenta_id ], case_sensitive: false, :message => "Categoria ya está registrada." }

  def self.create_update_categoria_entidad_contable(parametros, is_save=false)
    res                     = Response.new
    parametros              = CategoriaEntidadContable.check_params(parametros)

    CategoriaEntidadContable.transaction do

      parametros[:categoria_entidad_contable][:categorias].each do | params |

        cate_entidad_cont    = CategoriaEntidadContable.where(:id => params[:id]).first_or_create

        cate_entidad_cont.configuracion_entidad_cuenta_id            = params[:configuracion_entidad_cuenta_id]
        cate_entidad_cont.descripcion                                = params[:descripcion]
        cate_entidad_cont.entidad                                    = cate_entidad_cont.configuracion_entidad_cuenta.entidad
        cate_entidad_cont.key                                        = cate_entidad_cont.configuracion_entidad_cuenta.key

        result_procesos                                              = cate_entidad_cont.procesos_crear_cuenta(params)

        cate_entidad_cont.valid?
        if result_procesos.status_valid && cate_entidad_cont.errors.empty? && (!is_save || (is_save && cate_entidad_cont.save!))

          res.set_data(cate_entidad_cont)

          action = params[:id] ? 'actualizada' : 'creada'
          res.add_msg("Categoria de #{CatEntidadContable.tipos[cate_entidad_cont.entidad]} #{action} correctamente.")

        else
          res.add_msgs(result_procesos.get_msgs.to_a)
          res.add_msgs(cate_entidad_cont.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])

          transaction_rollback
          return res
        end
      end

    end

    return res

  end
  # ============================================================================================================================================

  def self.check_params(params)
    params[:categoria_entidad_contable] = {categorias: [ params[:categoria_entidad_contable] ]}.with_indifferent_access unless params[:categoria_entidad_contable][:categorias].present?
    return params
  end

  # ============================================================================================================================================

  def procesos_crear_cuenta(params)
    res = Response.new

    configuracion                                   = self.configuracion_entidad_cuenta

    descripcion_cuenta                              = "#{ConfigEntidadCuentaCont::Keys.label[:"#{configuracion.key}"]} categoria: #{self.descripcion}"
    cuenta_contable_db                              = CuentaContable.find_by("lower(descripcion) like lower('#{descripcion_cuenta}') AND cuenta_control=#{configuracion.cuenta_contable_id}")

    if cuenta_contable_db.nil?
      if self.cuenta_contable_control_id.nil?
        res                                         = CatEntidadContable.createCuenta(configuracion.cuenta_contable, descripcion_cuenta, true)
        cuenta_contable_control                     = res.get_data()

        self.cuenta_contable_control_id             = cuenta_contable_control[:id] if res.status_valid

      else
        self.cuenta_contable_control.descripcion    = descripcion_cuenta.upcase
        self.cuenta_contable_control.save!
      end
    else

      self.cuenta_contable_control_id               = cuenta_contable_db.id
    end


    if res.status_valid && configuracion.has_comun
      descripcion_cuenta                            = "#{ConfigEntidadCuentaCont::Keys.label[:"#{configuracion.key}"]} común: #{self.descripcion}"
      cuenta_contable_db                            = CuentaContable.find_by("lower(descripcion) like lower('#{descripcion_cuenta}') AND cuenta_control=#{self.cuenta_contable_control.id}")

      if cuenta_contable_db.nil?
        if self.cuenta_contable_auxiliar_id.nil?
          res                                       = CatEntidadContable.createCuenta(self.cuenta_contable_control, descripcion_cuenta, false)
          cuenta_contable_auxiliar                  = res.get_data()
          self.cuenta_contable_auxiliar_id          = cuenta_contable_auxiliar[:id]
        else
          self.cuenta_contable_auxiliar.descripcion = descripcion_cuenta
          self.cuenta_contable_auxiliar.save!
        end
      else
        self.cuenta_contable_auxiliar_id            = cuenta_contable_db.id
      end

    end

    return res
  end


end
