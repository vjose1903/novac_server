class DocumentoDeIdentidad < ApplicationRecord
  self.table_name = "documentos_de_identidad"
  belongs_to :user, optional: true
  belongs_to :cliente, optional: true
  belongs_to :suplidor, optional: true

  belongs_to :origen, polymorphic: true

  validates :documento, uniqueness: { scope: :origen_type, case_sensitive: false, :message => "Documento de identidad ya esta registrado" }

  def self.get_documentos_by_user_id(id)
    return my_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE user_id = #{id}")
  end

  def self.get_documentos_by_cliente_id(id)
    return my_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE cliente_id = #{id}")
  end

  def self.get_documentos_by_suplidor_id(id)
    return my_query("SELECT id, user_id, descripcion, documento, principal, created_at, updated_at, cliente_id, suplidor_id FROM documentos_de_identidad WHERE suplidor_id = #{id}")
  end


  def self.crear_actualizar_documento(params, padre, is_save=false)
    res = Response.new
    puts "------- ENTRANDO A CREAR EL DOCUMENTO -------".red
    puts "params: ".yellow + "#{params.to_json}"
    unless params["id"]
      documento = DocumentoDeIdentidad.new
    else
      documento = DocumentoDeIdentidad.find_by_id(params["id"])
    end

    documento.descripcion = params["descripcion"]
    documento.documento = params["documento"]
    documento.principal = params["principal"]
    documento.origen = padre

    documento.valid?

    if documento.errors.to_a.empty? && (!is_save || (is_save && documento.save!))
      res.set_data(documento)
    else
      res.add_msgs(documento.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.validar_e_inicializar(documentos, padre, save)
    res_valid = Response.new
    array_valid=[]

    puts " "
    puts " "
    puts "documentos --> ".blue + "#{documentos.to_json}"
    
    documentos.each do |documento|
      puts " "
      puts " "
    puts "documento --> ".green + "#{documento.to_json}"
      res_temp = self.crear_actualizar_documento(documento, padre, save)
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
