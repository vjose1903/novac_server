class FacturacionElectronicaController < ApplicationController
  before_action :validate_xml_file,  only: [:recepcion, :aprobacion_comercial]

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
        receptionData = receptionDB.get_data

        response  = DGII_MANAGER.reception( { xml: @xml_content, fileName: receptionData.xml_file_name} )
        render xml: response.get_data[:xml], status: :ok, content_type: "application/xml"
      else
        render json: { isValid: false, message: receptionDB.get_msgs.to_a.join(", ") }, status: :bad_request
      end

    else
      render json: { isValid: validation[:isValid], message: validation[:message] }, status: :bad_request
    end

  end




  def aprobacion_comercial

    validation = FacturacionElectronica.validate_reception_commercial_approval(@xml_content)

    if validation[:isValid]

      approvedDB = CommertialApprovalReception.create_new(validation[:values], true)

      if approvedDB.status_valid
        approvedData = approvedDB.get_data

        validation = DGII_MANAGER.validate_commercial_approval( { xml: @xml_content, fileName: approvedData.xml_file_name } )
        response   = validation.get_data

        isValid = response[:isValid]

        if isValid
          render json: { isValid: isValid }, status: :ok
        else
          render json: { isValid: isValid }, status: :bad_request
        end

      else
        render json: { isValid: false, message: receptionDB.get_msgs.to_a.join(", ") }, status: :bad_request
      end

    else
      render json: { isValid: validation[:isValid], message: validation[:message] }, status: :bad_request
    end
  end

  def login_prueba
    res = Response.new(nil, HTTP_STATUS_CODE[:conflict], nil, ['Error realizando la prueba'])
    begin
    validation = DGII_MANAGER.auth_test

    validation.send_response self
    rescue  StandardError => e
      res.set_data(e)
      res.send_response self
    end
  end
end
