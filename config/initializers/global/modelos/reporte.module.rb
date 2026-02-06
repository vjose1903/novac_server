module Report
  module CxC
    TIPOS = {
      por_cliente: '1',
      detallado:   '2',
      agrupado:    '3',
      historico:   '4',
    }

    def self.por_cliente
      return TIPOS[:por_cliente]
    end

    def self.detallado
      return TIPOS[:detallado]
    end

    def self.agrupado
      return TIPOS[:agrupado]
    end

    def self.historico
      return TIPOS[:historico]
    end

  end

  module CxP
    TIPOS = {
      por_suplidor: '1',
      detallado:    '2',
      agrupado:     '3',
    }

    def self.por_suplidor
      return TIPOS[:por_suplidor]
    end

    def self.detallado
      return TIPOS[:detallado]
    end

    def self.agrupado
      return TIPOS[:agrupado]
    end

  end

  module PagoFactura
    TIPOS = {
      detallado:    'detallado',
      agrupado:     'agrupado',
    }

    def self.detallado
      return TIPOS[:detallado]
    end

    def self.agrupado
      return TIPOS[:agrupado]
    end
  end

  module ReciboIngreso
    TIPOS = {
      detallado:    'detallado',
      agrupado:     'agrupado',
    }

    def self.detallado
      return TIPOS[:detallado]
    end

    def self.agrupado
      return TIPOS[:agrupado]
    end
  end
  
  module ReciboBuscarPor
    TIPOS = {
      general:        1,
      por_cliente:    2,
    }

    def self.general
      return TIPOS[:general]
    end

    def self.por_cliente
      return TIPOS[:por_cliente]
    end
  end

  module NotaBuscarPor
    TIPOS = {
      general:        1,
      por_cliente:    2,
    }

    def self.general
      return TIPOS[:general]
    end

    def self.por_cliente
      return TIPOS[:por_cliente]
    end
  end
end