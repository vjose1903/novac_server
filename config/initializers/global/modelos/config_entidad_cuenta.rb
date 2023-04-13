module ConfigEntidadCuentaCont
  # keys en configuraciones
  KEYS = {
    COBRAR:             'cobrar',
    PAGAR:              'pagar',
    RETENCION:          'retencion',
    EFECTIVO_BANCO:     'efectivo_banco',
    INVENTARIO:         'inventario',
    VENTAS:             'ventas',
    DESCUENTO_VENTAS:   'descuento_ventas',
    COMPRAS:            'compras',
    DESCUENTO_COMPRAS:  'descuento_compras'
  }.with_indifferent_access

  # tipos de entidades
  TIPO = {
    CLIENTE:          'cliente',
    SUPLIDOR:         'suplidor',
    USER:             'user',
    CUENTA_BANCARIA:  'cuenta_bancaria',
    ARTICULO:         'articulo'
  }.with_indifferent_access



  def self.tipo
    return TIPO
  end

  def self.cliente
    return TIPO[:CLIENTE]
  end
  def self.suplidor
    return TIPO[:SUPLIDOR]
  end

  def self.user
    return TIPO[:USER]
  end

  def self.cuenta_bancaria
    return TIPO[:CUENTA_BANCARIA]
  end

  def self.articulo
    return TIPO[:ARTICULO]
  end

#  --------------------------------------------------------------------------------
  module Cliente
    def self.cobrar
      return KEYS[:COBRAR]
    end
  end

  #  --------------------------------------------------------------------------------
  module Suplidor
    def self.pagar
      return KEYS[:PAGAR]
    end
  end

  #  --------------------------------------------------------------------------------
  module User
    def self.cobrar
      return KEYS[:COBRAR]
    end

    def self.pagar
      return KEYS[:PAGAR]
    end

    def self.retencion
      return KEYS[:RETENCION]
    end
  end

  #  --------------------------------------------------------------------------------
  module CuentaContable
    def self.efectivo_banco
      return KEYS[:EFECTIVO_BANCO]
    end
  end

  #  --------------------------------------------------------------------------------
  module Articulo
    def self.inventario
      return KEYS[:INVENTARIO]
    end

    def self.ventas
      return KEYS[:VENTAS]
    end

    def self.descuento_ventas
      return KEYS[:DESCUENTO_VENTAS]
    end

    def self.compras
      return KEYS[:COMPRAS]
    end

    def self.descuento_compras
      return KEYS[:DESCUENTO_COMPRAS]
    end
  end

#  --------------------------------------------------------------------------------

  module Keys

		LABELS = {
			COBRAR:             'cuentas por cobrar',
			PAGAR:              'cuentas por pagar',
			RETENCION:          'retencion',
			EFECTIVO_BANCO:     'efectivo en banco',
			INVENTARIO:         'inventario',
			VENTAS:             'ventas',
			DESCUENTO_VENTAS:   'descuento sobre ventas',
			COMPRAS:            'compras',
			DESCUENTO_COMPRAS:  'descuento sobre compras',
		}.with_indifferent_access

    def self.get_label(key)
      return LABELS[:"#{key}"]
    end
  end
#  --------------------------------------------------------------------------------
end

TIPOS_DE_ENTIDADES_VALIDOS = [ ConfigEntidadCuentaCont.cliente, ConfigEntidadCuentaCont.suplidor, ConfigEntidadCuentaCont.user, ConfigEntidadCuentaCont.cuenta_bancaria, ConfigEntidadCuentaCont.articulo ]