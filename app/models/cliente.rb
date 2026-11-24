class Cliente < ApplicationRecord
  after_initialize :init, if: :new_record?

  belongs_to :imagen, optional: true
  belongs_to :municipio, optional: true,                  class_name: 'Municipio'
  belongs_to :vendedor, optional: true,                  class_name: 'User'

  has_many  :documentos_de_identidad,    :as => :origen,           dependent: :destroy, class_name: 'DocumentoDeIdentidad'
  has_many  :entidad_cuentas_contables,  :as => :origen_entidad,   dependent: :destroy, class_name: 'EntidadCuentaContable'
  has_many  :imagenes,                   :as => :origen_img,       dependent: :destroy, class_name: 'Imagen'
  has_one   :provincia,                                                                 class_name: 'Provincia', through: :municipio

  validates :nombre,              presence: { :message => 'Nombre del cliente no puede estar vacío.' },         uniqueness: { scope: [:estado, :apellido], case_sensitive: false, :message => 'Cliente ya está registrado' }, :if => :estado
  validates :apellido,            presence: { :message => 'Apellido del cliente no puede estar vacío.' }
  validates :telefono,            presence: { :message => 'Telefono del cliente no puede estar vacío.' }
  validates :sexo,                presence: { :message => 'Sexo del cliente no puede estar vacío.' }
  validates :limite_credito,      presence: { :message => 'Dias de crédito del cliente no puede estar vacío.' }
  validates :maximo_credito,      presence: { :message => 'Cantidad de crédito del cliente no puede estar vacío.' }
  validates :vendedor_id,         presence: { :message => 'Debe de seleccionar un vendedor para el cliente.' }
  validates :direccion,           presence: { :message => 'Direccion del cliente no puede estar vacío.' }
  validates :municipio,           presence: { :message => 'Municipio del cliente no puede estar vacío.' }, if: -> { create_validations }

  attr_accessor :create_validations

  # =========================================================================================================================================================

  def otras_validaciones(params, has_contabilidad)
    if has_contabilidad
      cliente_configs = ConfiguracionEntidadCuenta.where(:entidad => ConfigEntidadCuentaCont.suplidor)

      if !params.has_key?(:cuentas_contables) || params[:cuentas_contables].nil? || ( cliente_configs.length < params[:cuentas_contables].length )
        self.errors.add(:base, 'Debe de especificar todos los atributos para cuentas contables.')
      end
    end
  end



  def init
    self.balance = 0                unless self.balance
  end

  # =========================================================================================================================================================

  def self.models_includes
    includes = [
      :documentos_de_identidad,
      :imagen,
      :imagenes,
      :municipio,
      :provincia,
      :vendedor,
      { entidad_cuentas_contables: [ :cuenta_contable, :configuracion_entidad_cuenta ] },
    ]
    return includes
  end

  def self.filter_order_columns
    {
      'id' => 'clientes.id', 'nombre' => 'clientes.nombre', 'apellido' => 'clientes.apellido',
      'telefono' => 'clientes.telefono', 'direccion' => 'clientes.direccion',
      'limite_credito' => 'clientes.limite_credito', 'maximo_credito' => 'clientes.maximo_credito',
      'balance' => 'clientes.balance', 'created_at' => 'clientes.created_at', 'updated_at' => 'clientes.updated_at'
    }
  end

  def self.parse_filter_order(order_by)
    ORDER_MANAGER.parse_safe(order_by, filter_order_columns, 'clientes.id ASC')
  end

  # =========================================================================================================================================================

  def nombre_completo
    nombre    = self.nombre.capitalize
    nombre    += " #{self.apellido.capitalize}" unless self.apellido.blank?
    nombre    = nombre.gsub('  ', ' ').strip
    nombre
  end

  # =========================================================================================================================================================

  def self.create_update_cliente(params , is_save=false)
    res                            = Response.new
    has_contabilidad                = system_has_contabilidad

    Cliente.transaction do

      cliente                      = Cliente.where(:id => params[:id]).first_or_initialize

      cliente.imagen_id            = params[:imagen_id]                       if params.obj_has?(:imagen_id)
      cliente.nombre               = params[:nombre]                          if params.obj_has?(:nombre)
      cliente.apellido             = params[:apellido]                        if params.obj_has?(:apellido)
      cliente.limite_credito       = params[:limite_credito]                  if params.obj_has?(:limite_credito)
      cliente.telefono             = params[:telefono]                        if params.obj_has?(:telefono)
      cliente.direccion            = params[:direccion]                       if params.obj_has?(:direccion)
      cliente.sexo                 = params[:sexo]                            if params.obj_has?(:sexo)
      cliente.maximo_credito       = params[:maximo_credito]                  if params.obj_has?(:maximo_credito)
      cliente.vendedor_id          = params[:vendedor_id]                     if params.obj_has?(:vendedor_id)
      cliente.municipio_id         = params[:municipio_id]                    if params.obj_has?(:municipio_id)
      cliente.estado               = true

      cliente.create_validations   = true
      cliente.valid?

      cliente.otras_validaciones(params, has_contabilidad)

      if has_contabilidad
        cuentas_config = { view_prima: false, tipo_categoria: CatContable.categoria_entidad_contable, descripcion_cuenta: cliente.nombre_completo }.with_indifferent_access
        EntCuentaContable.parsear_cuentas_contables(params, cuentas_config, true ) if cliente.errors.empty?
      end

      if cliente.errors.empty?
        dependencias = [
          { modelo: DocumentoDeIdentidad,  key_object: 'documentos_de_identidad',     padre: cliente },
          { modelo: Imagen,                key_object: 'imagenes',                    padre: cliente }
        ]

        dependencias.push({ modelo: EntidadCuentaContable, key_object: 'entidad_cuentas_contables', padre: cliente }) if has_contabilidad

        res = crear_actualizar_dependencias(dependencias, params) { |key_object, dependencia_data|
          cliente.documentos_de_identidad    = dependencia_data if key_object == 'documentos_de_identidad'
          cliente.entidad_cuentas_contables  = dependencia_data if key_object == 'entidad_cuentas_contables'
          cliente.imagenes                   = dependencia_data if key_object == 'imagenes'
        }

        if res.status_valid && cliente.save!
          res.set_data(serialize_parser(cliente, {all: true}))

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Cliente #{action} correctamente.")
        end
      end


      unless cliente.errors.empty?
        res.add_msgs(cliente.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !cliente.errors.empty? || !res.status_valid
    end

    return res
  end

  # =========================================================================================================================================================

  def self.filtrarCliente(arg, paginate_options)
    res = Response.new(paginate_options)
    # Divide la búsqueda en palabras individuales
    palabras_busqueda = arg.to_s.downcase.split

    # Empieza con todos los clientes activos
    query = Cliente.where(estado: true)
                   .joins("LEFT JOIN documentos_de_identidad ON clientes.id = documentos_de_identidad.origen_id
            AND documentos_de_identidad.origen_type = 'Cliente'
            AND documentos_de_identidad.principal = true")

    query = query.where('clientes.sexo IS NOT NULL').distinct

    palabras_busqueda.each do |palabra|
      palabra = "%#{ActiveRecord::Base.sanitize_sql_like(palabra)}%"
      query = query.where("immutable_unaccent(clientes.nombre) ILIKE immutable_unaccent(:palabra) OR immutable_unaccent(clientes.apellido) ILIKE immutable_unaccent(:palabra) OR immutable_unaccent(documentos_de_identidad.documento) ILIKE immutable_unaccent(:palabra)", palabra: palabra)
    end

    clientes = query.order(Arel.sql(parse_filter_order(paginate_options['order_by'])))

    if clientes.exists?
      res.set_data(clientes, { all: true }, Cliente.models_includes)
    else
      res.set_data([])
      cantidad_registros = Cliente.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen clientes registrados.' : 'No existe cliente con las especificaciones introducidas.')
      res.set_empty_collection_status(cantidad_registros)
    end

    return res
  end



  # =========================================================================================================================================================
  def get_balances_and_facturas(params, paginate_options)
    paginate_class               = Paginator.new(paginate_options)
    res                          = Response.new()
    cliente_en_turno             = self
    order_columns = CabeceraFactura.column_names.each_with_object({}) do |column, allowed|
      allowed[column] = "cabecera_facturas.#{column}"
    end
    order_by = ORDER_MANAGER.parse_safe(params[:order_by], order_columns, 'cabecera_facturas.id DESC')

    factura_a_buscar             = params[:factura_a_buscar]
    next_page                    = nil

    data       = {'balances' => { 'total_facturado' => 0, 'notas_credito' => 0, 'notas_debito' => 0, 'debiendo' => 0, 'abonado' => 0}, 'facturas' => [], 'page' => paginate_class.get_page}

    facturas   = CabeceraFactura
                   .where('cabecera_facturas.balance >= ?', 1)
                   .where(pagada: false, tipo: %w[venta pre_venta], estado: true, cliente_id: cliente_en_turno.id)
                   .order(Arel.sql(order_by))
                   .includes(CabeceraFactura.models_includes).each do | factura |

      data['balances']['total_facturado'] += factura.total_factura
      data['balances']['debiendo']        += factura.balance

      facturas_aplicadas = factura.facturas_aplicadas.select { |factura_aplicada| factura_aplicada.nota.estado }

      tipos_nota_credito = [TiposNotasId.credito, TiposNotasId.credito_electronica]
      notas_credito      = facturas_aplicadas.select { | factura_aplicada | tipos_nota_credito.include?(factura_aplicada.nota.tipo_factura_id) }

      tipos_nota_debito  = [TiposNotasId.debito, TiposNotasId.debito_electronica]
      notas_debito       = facturas_aplicadas.select { | factura_aplicada | tipos_nota_debito.include?(factura_aplicada.nota.tipo_factura_id) }

      data['balances']['notas_credito']   += notas_credito.reduce(0) { | acu, item |  (item.total).abs + acu }
      data['balances']['notas_debito']    += notas_debito.reduce(0) { | acu, item |  (item.total).abs + acu }

      recibos                              = factura.detalle_recibos
      data['balances']['abonado']         += recibos.reduce(0) { | acu, item |  item.deposito + acu }

    end

    unless factura_a_buscar.nil?
      index_factura_a_buscar = facturas.index { |fact| "#{fact.id}" == "#{factura_a_buscar}" }
      unless index_factura_a_buscar.nil?
        next_page            = (index_factura_a_buscar / paginate_class.get_per_page.to_f).ceil
        next_page            = 1 if next_page == 0

        paginate_class.set_page(next_page)
        data['page']         = paginate_class.get_page
      end
    end

    paginate_class.paginate_data(facturas)

    data['facturas']         = paginate_class.data_paginated
    data['facturas']['data'] = serialize_parser(paginate_class.get_data, { all: true, movimientos_viaje: true })

    res.set_data(data)
    return res

  end
  # =========================================================================================================================================================

  def self.calculate_balance_cliente(id, totalFactura, operacion, ignoreMontoMayor=false)

    res = Response.new

    cliente          = Cliente.find_by_id(id)
    balance          = cliente.balance.nil? ? 0 : cliente.balance


    if operacion == '-' && totalFactura.to_f > balance
      unless ignoreMontoMayor
        res.add_msg('El monto ingresado es mayor al balance del cliente.')
        res.set_status(HTTP_STATUS_CODE[:conflict])
        return res
      end
    end

    new_balance                  = eval "#{balance} #{operacion} #{totalFactura.to_f}"
    new_balance                  = new_balance.to_d.truncate(2).to_f
    cliente.balance              = new_balance

    cliente.valid?

    if !cliente.errors.empty? || !cliente.save!
      res.add_msgs(cliente.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  private
end
