class FacturacionElectronica

    def self.validate_reception_ecf(xml)
        doc = Nokogiri::XML(xml)
        
        ecf_reception = {
            eNCF: doc.xpath("//eNCF")&.text,
            rnc_emisor: doc.xpath("//RNCEmisor")&.text,
            rnc_comprador: doc.xpath("//RNCComprador")&.text,
            monto_total: doc.xpath("//MontoTotal")&.text,
            fecha_emision: doc.xpath("//FechaEmision")&.text
        }

        ecf_valid = !ecf_reception.values.any?(&:empty?)

        message = ecf_valid ? "" : "El archivo eCF no es valido"
        
        { isValid: ecf_valid, values: ecf_reception, message: message }.with_indifferent_access
    end

    def self.validate_reception_commercial_approval(xml)
        doc = Nokogiri::XML(xml)
        
        ecf_reception = {
            eNCF: doc.xpath("//eNCF")&.text,
            rnc_emisor: doc.xpath("//RNCEmisor")&.text,
            rnc_comprador: doc.xpath("//RNCComprador")&.text,
            monto_total: doc.xpath("//MontoTotal")&.text,
            fecha_emision: doc.xpath("//FechaEmision")&.text,
            estado: doc.xpath("//Estado")&.text
        }

        ecf_valid = !ecf_reception.values.any?(&:empty?)

        ecf_reception[:detalleMotivoRechazo] = doc.xpath("//DetalleMotivoRechazo")&.text || ''

        puts "ecf_reception: #{ecf_reception}".yellow

        message = ecf_valid ? "" : "El archivo XML no es valido"
        
        { isValid: ecf_valid, values: ecf_reception, message: message }.with_indifferent_access
    end

end