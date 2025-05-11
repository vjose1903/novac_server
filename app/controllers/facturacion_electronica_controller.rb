class FacturacionElectronicaController < ApplicationController
  before_action :validate_xml_file

  if ENV["RAILS_ENV"] != "development"
    skip_before_action :validateUserIsLogging!
  end

  def validate_xml_file
    xml_file = params[:xml]
    
    if xml_file.content_type != "application/xml" && xml_file.content_type != "text/xml"
      render json: { error: "El archivo XML es requerido" }, status: :bad_request
    end

    if params[:xml].blank?
      render json: { error: "El archivo XML es requerido" }, status: :bad_request
    end
    
    @xml_content = xml_file.read

  end



  def recepcion
    validation = FacturacionElectronica.validate_reception_ecf(@xml_content)

    if validation[:isValid]
      
      receptionDB = EcfReception.create_new(validation[:values], true)
      
      if receptionDB.status_valid
        response  = DGII_MANAGER.reception( { xml: @xml_content } )
        render xml: response.get_data[:xml], status: :ok, content_type: "application/xml"
      else
        render json: { isValid: false, message: receptionDB.get_msgs.to_a.join(", ") }, status: :bad_request
      end

    else
      render json: { isValid: validation[:isValid], message: validation[:message] }, status: :bad_request
    end

  end
  
  
  
  
  def aprobacion_comercial
    puts "@xml_content:".yellow + " #{@xml_content}"
    
    validation = DGII_MANAGER.validate_commercial_approval( { xml: @xml_content } )
    response   = validation.get_data

    isValid = response[:isValid]

    if isValid
      render json: { isValid: isValid }, status: :ok
    else
      render json: { isValid: isValid }, status: :bad_request
    end
  end
end
