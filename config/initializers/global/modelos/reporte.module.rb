module Report
  module CxC
    TIPOS = {
      por_cliente: '1',
      detallado:   '2',
      agrupado:    '3',
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

  end
end