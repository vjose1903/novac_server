class Cliente < ApplicationRecord
  
  belongs_to :imagen, optional: true
  accepts_nested_attributes_for :imagen

  has_many :documentos_de_identidad, :as => :origen, dependent: :destroy, class_name: "DocumentoDeIdentidad"

  validates :nombre,              presence: { :message => "Nombre del cliente no puede estar vacio." },         uniqueness: { scope: [:estado, :apellido], case_sensitive: false, :message => "Cliente ya esta registrado" }, :if => :estado
  validates :apellido,            presence: { :message => "Apellido del cliente no puede estar vacio." }
  validates :telefono,            presence: { :message => "Telefono del cliente no puede estar vacio." }
  validates :sexo,                presence: { :message => "Sexo del cliente no puede estar vacio." }
  validates :limite_credito,      presence: { :message => "Dias de crédito del cliente no puede estar vacio." }
  validates :maximo_credito,      presence: { :message => "Cantidad de crédito del cliente no puede estar vacio." }
  validates :vendedor_id,         presence: { :message => "Debe de seleccionar un vendedor para el cliente." }
  validates :direccion,           presence: { :message => "Direccion del cliente no puede estar vacio." }

  def init
    self.balance = 0 unless self.balance
  end

  # =========================================================================================================================================================

  def self.create_update_cliente(params , is_save=false)
    Cliente.transaction do
      res = Response.new
      
      unless params["id"]
        cliente = Cliente.new()
      else
        cliente = Cliente.find_by_id(params["id"])
      end

      cliente.imagen_id            = params["imagen_id"]
      cliente.nombre               = params["nombre"]
      cliente.apellido             = params["apellido"]
      cliente.limite_credito       = params["limite_credito"]
      cliente.telefono             = params["telefono"]
      cliente.direccion            = params["direccion"]
      cliente.sexo                 = params["sexo"]
      cliente.maximo_credito       = params["maximo_credito"]
      cliente.vendedor_id          = params["vendedor_id"]
      cliente.balance              = params["balance"] ? params["balance"] : 0
      cliente.estado               = true
      
      cliente.valid?
      
      if cliente.errors.empty? 
        dependencias = [{modelo:DocumentoDeIdentidad, key_object:"documentos_de_identidad", padre:cliente}]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data| 
          cliente.documentos_de_identidad = dependencia_data if key_object == 'documentos_de_identidad'
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
        return res
        raise ActiveRecord::Rollback
      end

      return res
    end

  end


  
  # =========================================================================================================================================================

  def self.filtrarCliente(arg, params)
    res = Response.new(params)

    clientes = Cliente
    .joins("left join documentos_de_identidad on clientes.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'Cliente' AND documentos_de_identidad.principal = true")
    .where("lower(clientes.nombre || ' ' || clientes.apellido || ' ' || coalesce(documentos_de_identidad.documento, '')) like lower('%#{arg}%')  AND clientes.estado = true AND clientes.sexo IS NOT NULL")
    .order("clientes.id ASC").to_a

    if clientes.length > 0  
      res.set_data(clientes, {all: true})
    else
      res.set_data([])
      res.add_msg("No existe cliente con las especificaciones introducidas")
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================
  def self.checkBalanceClientes()
    Cliente.all.each do |cliente|

      sumBalance = my_query("select coalesce(sum(cabecera_facturas.balance),0) + (select coalesce(sum(nota.total_factura),0) from cabecera_facturas nota where nota.aplicada_a = numero_comprobante) as balance from cabecera_facturas where cliente_id = #{cliente.id}")
      balanceCalc = sumBalance[0]['balance']
      
      if balanceCalc != cliente.balance
        cliente.balance = balanceCalc
        
        unless cliente.save!
          sendEmail("Error recalculando el balance del cliente: #{cliente.nombre} #{cliente.apellido}  -- ID: #{cliente.id}", "Error en la tarea de recalcular balance")
        end
      end
    end

    return "LISTO"
  end
    # =========================================================================================================================================================
    
  def self.calculate_balance_cliente(id, totalFactura, operacion, ignoreMontoMayor=false)

    res = Response.new

    cliente          = Cliente.find_by_id(id)
    balance          = cliente["balance"].nil? ? 0 : cliente["balance"]
    
    if operacion == "-" && totalFactura.to_f > balance
      unless ignoreMontoMayor
        res.add_msg("El monto ingresado es mayor al balance del cliente")
        res.set_status(HTTP_STATUS_CODE[:conflict])
        return res
      end
    end
    
    new_balance      = eval "#{balance} #{operacion} #{totalFactura.to_f}"
    new_balance      = new_balance.to_d.truncate(2).to_f
    cliente.balance  = new_balance

    cliente.valid?

    # unless cliente.errors.empty? || !cliente.save!
    unless cliente.errors.empty? 
      res.add_msgs(cliente.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
