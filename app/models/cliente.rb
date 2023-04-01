class Cliente < ApplicationRecord
  belongs_to  :categoria_entidad_contable, optional: true
  has_many    :documentos_de_identidad,    :as => :origen,         dependent: :destroy, class_name: 'DocumentoDeIdentidad'
  has_many    :entidad_cuentas_contables,  :as => :origen_entidad, dependent: :destroy, class_name: 'EntidadCuentaContable'

  validates :nombre,              presence: { :message => 'Nombre del cliente no puede estar vacio.' },         uniqueness: { scope: [:estado, :apellido], case_sensitive: false, :message => 'Cliente ya está registrado' }, :if => :estado
  validates :apellido,            presence: { :message => 'Apellido del cliente no puede estar vacio.' }
  validates :telefono,            presence: { :message => 'Telefono del cliente no puede estar vacio.' }
  validates :sexo,                presence: { :message => 'Sexo del cliente no puede estar vacio.' }
  validates :limite_credito,      presence: { :message => 'Dias de crédito del cliente no puede estar vacio.' }
  validates :maximo_credito,      presence: { :message => 'Cantidad de crédito del cliente no puede estar vacio.' }
  validates :vendedor_id,         presence: { :message => 'Debe de seleccionar un vendedor para el cliente.' }
  validates :direccion,           presence: { :message => 'Direccion del cliente no puede estar vacio.' }

  def init
    self.balance = 0 unless self.balance
  end




  def self.models_includes
    includes = [:documentos_de_identidad, :entidad_cuentas_contables]
    return includes
  end

  def nombre_completo
    nombre    = self.nombre.capitalize
    nombre    += " #{self.apellido.capitalize}" unless self.apellido.blank?
    nombre    = nombre.gsub('  ',' ').strip
    nombre
  end

  # =========================================================================================================================================================

  def self.create_update_cliente(params , is_save=false)
    res                            = Response.new
    Cliente.transaction do

      cliente                      = Cliente.where(:id => params[:id]).first_or_create

      cliente.nombre                          = params[:nombre]
      cliente.apellido                        = params[:apellido]
      cliente.limite_credito                  = params[:limite_credito]
      cliente.telefono                        = params[:telefono]
      cliente.direccion                       = params[:direccion]
      cliente.sexo                            = params[:sexo]
      cliente.maximo_credito                  = params[:maximo_credito]
      cliente.vendedor_id                     = params[:vendedor_id]
      cliente.balance                         = params[:balance] ? params[:balance] : 0
      cliente.categoria_entidad_contable_id   = params[:categoria_entidad_contable_id]
      cliente.estado                          = true

      cliente.valid?

      if cliente.errors.empty?
        dependencias = [
          { modelo:DocumentoDeIdentidad,   key_object: 'documentos_de_identidad',   padre: cliente },
          { modelo: EntidadCuentaContable, key_object: 'cuentas_contables', padre: cliente }
        ]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
          cliente.documentos_de_identidad    = dependencia_data if key_object == 'documentos_de_identidad'
          cliente.entidad_cuentas_contables  = dependencia_data if key_object == 'cuentas_contables'
        }

        if res.status_valid && cliente.save!
          res.set_data(serialize_parser(cliente, {all: true}))

          action = params["id"] ? 'actualizado' : 'creado'
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

  def self.filtrarCliente(arg, params)
    res = Response.new(params)

    clientes = Cliente
    .joins("left join documentos_de_identidad on clientes.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'Cliente' AND documentos_de_identidad.principal = true")
    .where("lower(clientes.nombre || ' ' || clientes.apellido || ' ' || coalesce(documentos_de_identidad.documento, '')) like lower('%#{arg}%')  AND clientes.estado = true AND clientes.sexo IS NOT NULL")
    .order('clientes.id ASC')

    if clientes.length > 0
      res.set_data(clientes, {all: true}, Cliente.models_includes)
    else
      res.set_data([])
      cantidad_registros = Cliente.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen clientes registrados.' : 'No existe cliente con las especificaciones introducidas.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end



  # =========================================================================================================================================================
  def get_balances_and_facturas(params, paginate_options)
    paginate_class               = Paginator.new(paginate_options)
    res                          = Response.new()
    cliente_en_turno             = self

    factura_a_buscar             = params[:factura_a_buscar]
    next_page       = nil
    next_page                    = nil

    query      = "cabecera_facturas.balance >= 1 AND NOT cabecera_facturas.pagada AND (cabecera_facturas.tipo = 'venta' OR cabecera_facturas.tipo = 'pre_venta') AND cabecera_facturas.estado = true  AND cabecera_facturas.cliente_id = #{cliente_en_turno.id}"

    data       = { balances: { total_facturado: 0, notas_credito: 0, notas_debito: 0, debiendo: 0, abonado: 0 }, facturas: [], page: paginate_class.get_page }.with_indifferent_access

    facturas   = CabeceraFactura.where(query).order('id DESC').includes(CabeceraFactura.models_includes).each do | factura |

      data[:balances][:total_facturado] += factura.total_factura
      data[:balances][:debiendo]        += factura.balance

      facturas_aplicadas                 = factura.facturas_aplicadas
      notas_credito                      = facturas_aplicadas.select { | factura_aplicada | factura_aplicada.nota.tipo_factura_id == TiposNotasId.credito }
      notas_debito                       = facturas_aplicadas.select { | factura_aplicada | factura_aplicada.nota.tipo_factura_id == TiposNotasId.debito }

      data[:balances][:notas_credito]   += notas_credito.reduce(0) { | acu, item |  (item.total).abs + acu }
      data[:balances][:notas_debito]    += notas_debito.reduce(0) { | acu, item |  (item.total).abs + acu }

      recibos                            = factura.detalle_recibos
      data[:balances][:abonado]         += recibos.reduce(0) { | acu, item |  item.deposito + acu }

    end

    unless factura_a_buscar.nil?
      index_factura_a_buscar   = facturas.index { |fact| "#{fact.id}" == "#{factura_a_buscar}" }

      unless index_factura_a_buscar.nil?
        next_page              = (index_factura_a_buscar / paginate_class.get_per_page.to_f).ceil
        next_page = 1 if next_page == 0

        paginate_class.set_page(next_page)
        data[:page]            = paginate_class.get_page
      end
    end

    paginate_class.paginate_data(facturas)

    data[:facturas]         = paginate_class.data_paginated
    data[:facturas][:data]  = serialize_parser(paginate_class.get_data, {all: true})

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

    new_balance      = eval "#{balance} #{operacion} #{totalFactura.to_f}"
    new_balance      = new_balance.to_d.truncate(2).to_f
    cliente.balance  = new_balance
    cliente.valid?

    if !cliente.errors.empty? || !cliente.save!
      res.add_msgs(cliente.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
