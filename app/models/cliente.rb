class Cliente < ApplicationRecord
  after_initialize :init, if: :new_record?

  belongs_to :imagen,    optional: true
  belongs_to :municipio, optional: true,                  class_name: 'Municipio'

  accepts_nested_attributes_for :imagen

  has_many :documentos_de_identidad, dependent: :destroy, class_name: 'DocumentoDeIdentidad', :as => :origen
  has_one  :provincia,                                    class_name: 'Provincia', through: :municipio

  validates :nombre,              presence: { :message => 'Nombre del cliente no puede estar vacio.' }
  validates :apellido,            presence: { :message => 'Apellido del cliente no puede estar vacio.' }
  validates :telefono,            presence: { :message => 'Telefono del cliente no puede estar vacio.' }
  validates :sexo,                presence: { :message => 'Sexo del cliente no puede estar vacio.' }
  validates :limite_credito,      presence: { :message => 'Dias de crédito del cliente no puede estar vacio.' }
  validates :maximo_credito,      presence: { :message => 'Cantidad de crédito del cliente no puede estar vacio.' }
  validates :vendedor_id,         presence: { :message => 'Debe de seleccionar un vendedor para el cliente.' }
  validates :direccion,           presence: { :message => 'Direccion del cliente no puede estar vacio.' }
  validates :municipio,           presence: { message: 'Municipio del cliente no puede estar vacio.' }, if: -> { create_validations }

  attr_accessor :create_validations

  def init
    self.balance = 0                unless self.balance
  end

  def self.models_includes
    includes = [:documentos_de_identidad, :municipio, :provincia]
    return includes
  end

  def nombre_completo
    nombre    = self.nombre.capitalize
    nombre    += " #{self.apellido.capitalize}" unless self.apellido.blank?
    nombre    = nombre.gsub('  ', ' ').strip
    nombre
  end

  # =========================================================================================================================================================

  def self.create_update_cliente(params , is_save=false)
    res                            = Response.new
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

      if cliente.errors.empty?
        dependencias = [{modelo: DocumentoDeIdentidad, key_object: 'documentos_de_identidad', padre: cliente}]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
          cliente.documentos_de_identidad = dependencia_data if key_object == 'documentos_de_identidad'
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

      raise ActiveRecord::Rollback if !cliente.errors.empty? || !res.status_valid
    end

    return res
  end


  # =========================================================================================================================================================

  def self.filtrarCliente(arg, params)
    res = Response.new(params)
    # Divide la búsqueda en palabras individuales
    palabras_busqueda = arg.to_s.downcase.split

    # Empieza con todos los clientes activos
    query = Cliente.where(estado: true)
                   .joins("LEFT JOIN documentos_de_identidad ON clientes.id = documentos_de_identidad.origen_id
            AND documentos_de_identidad.origen_type = 'Cliente'
            AND documentos_de_identidad.principal = true")

    # Aplica cada palabra como un filtro separado
    palabras_busqueda.each do |palabra|
      query = query.where("
      lower(clientes.nombre) LIKE :palabra OR
      lower(clientes.apellido) LIKE :palabra OR
      lower(COALESCE(documentos_de_identidad.documento, '')) LIKE :palabra",
                          palabra: "%#{palabra}%"
      )
    end

    # Ordena los resultados
    clientes = query.where('clientes.sexo IS NOT NULL').order("clientes.id ASC")

    if clientes.length > 0
      res.set_data(clientes, {all: true}, Cliente.models_includes)
    else
      res.set_data([])
      cantidad_registros = Cliente.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen clientes registrados.' : 'No existe cliente con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end



  # =========================================================================================================================================================
  def get_balances_and_facturas(params, paginate_options)
    paginate_class               = Paginator.new(paginate_options)
    res                          = Response.new()
    cliente_en_turno             = self
    order_by                     = ORDER_MANAGER.parse(params[:order_by])

    factura_a_buscar             = params[:factura_a_buscar]
    next_page                    = nil

    query      = "cabecera_facturas.balance >= 1 AND NOT cabecera_facturas.pagada AND (cabecera_facturas.tipo = 'venta' OR cabecera_facturas.tipo = 'pre_venta') AND cabecera_facturas.estado = true  AND cabecera_facturas.cliente_id = #{cliente_en_turno.id}"

    data       = {'balances' => { 'total_facturado' => 0, 'notas_credito' => 0, 'notas_debito' => 0, 'debiendo' => 0, 'abonado' => 0}, 'facturas' => [], 'page' => paginate_class.get_page}

    facturas   = CabeceraFactura.where(query).order(order_by ? order_by : 'id DESC').includes(CabeceraFactura.models_includes).each do | factura |

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
        next_page              = (index_factura_a_buscar / paginate_class.get_per_page.to_f).ceil
        next_page              = 1 if next_page == 0

        paginate_class.set_page(next_page)
        data['page']           = paginate_class.get_page
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

    if monto_mayor_al_balance?(operacion, totalFactura, balance, ignoreMontoMayor)
      res.add_msg('El monto ingresado es mayor al balance del cliente')
      res.set_status(HTTP_STATUS_CODE[:conflict])
      return res
    end

    cliente.balance = nuevo_balance_cliente(balance, totalFactura, operacion)

    cliente.valid?

    if !cliente.errors.empty? || !cliente.save!
      res.add_msgs(cliente.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.monto_mayor_al_balance?(operacion, totalFactura, balance, ignoreMontoMayor)
    operacion == '-' && totalFactura.to_f > balance && !ignoreMontoMayor
  end

  def self.nuevo_balance_cliente(balance, totalFactura, operacion)
    new_balance = operacion == '-' ? balance - totalFactura.to_f : balance + totalFactura.to_f
    new_balance.to_d.truncate(2).to_f
  end

  private
end
