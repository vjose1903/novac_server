class MetodoDePago < ApplicationRecord
  self.table_name = 'metodo_de_pago'

  FORMAS_PERMITIDAS = %w[Efectivo Cheque Tarjeta Transferencia].freeze

  belongs_to :metodo_de_pago_able, polymorphic: true

  validates :forma_pago, inclusion: { in: FORMAS_PERMITIDAS }
  validates :monto, numericality: { greater_than_or_equal_to: 0 }

  def self.normalizar(pagos, total, forma_pago_legacy)
    source = Array(pagos).presence || [{ forma_pago: forma_pago_legacy, monto: total }]
    lineas = source.map do |pago|
      forma_pago = pago[:forma_pago] || pago['forma_pago']
      monto = BigDecimal((pago[:monto] || pago['monto'] || 0).to_s).round(2)
      raise ArgumentError, 'La forma de pago no es válida.' unless FORMAS_PERMITIDAS.include?(forma_pago)
      raise ArgumentError, 'El monto de cada forma de pago debe ser mayor o igual a cero.' if monto.negative?

      { forma_pago: forma_pago, monto: monto }
    end
    raise ArgumentError, 'Debe indicar al menos una forma de pago.' if lineas.empty?
    total_documento = BigDecimal(total.to_s).round(2)
    total_pagado = lineas.sum { |pago| pago[:monto] }
    total_tarjeta = lineas.select { |pago| pago[:forma_pago] == 'Tarjeta' }.sum { |pago| pago[:monto] }
    tiene_otro_metodo = lineas.any? { |pago| pago[:forma_pago] != 'Tarjeta' }

    raise ArgumentError, 'La suma de las formas de pago no puede ser menor que el total del documento.' if total_pagado < total_documento
    if total_tarjeta > total_documento
      raise ArgumentError, 'El monto pagado con tarjeta no puede superar el total del documento.'
    end
    if total_pagado > total_documento && !tiene_otro_metodo
      raise ArgumentError, 'La devuelta debe corresponder a un método de pago distinto a tarjeta.'
    end

    lineas
  end

  def self.resumen(lineas)
    lineas.map { |pago| pago[:forma_pago] }.uniq.one? ? lineas.first[:forma_pago] : 'Mixto'
  end

  def self.reemplazar!(documento, lineas)
    documento.metodos_de_pago.destroy_all
    lineas.each { |pago| documento.metodos_de_pago.create!(pago) }
  end
end
