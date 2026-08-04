module CuadreCajas
  class SystemIncomeCalculator
    PAYMENT_METHODS = %w[Efectivo Cheque Tarjeta Transferencia].freeze

    def self.call(closing_date)
      new(closing_date).call
    end

    def initialize(closing_date)
      @closing_date = Date.parse(closing_date.to_s)
    end

    def call
      invoices_total = final_consumer_invoices_total
      receipts_total = income_receipts_total
      invoice_breakdown = invoices_by_payment_method
      receipt_breakdown = receipts_by_payment_method

      {
        final_consumer_invoices_total: decimal_string(invoices_total),
        income_receipts_total: decimal_string(receipts_total),
        system_income_total: decimal_string(invoices_total + receipts_total),
        payment_methods: payment_methods_summary(invoice_breakdown, receipt_breakdown),
        invoice_payment_methods: format_payment_methods(invoice_breakdown),
        receipt_payment_methods: format_payment_methods(receipt_breakdown),
        invoices: invoice_documents,
        receipts: receipt_documents,
        details: {
          calculated_at: Time.zone.now,
          closing_date: @closing_date,
          invoice_criteria: invoice_criteria,
          payment_methods: PAYMENT_METHODS
        }
      }
    end

    private

    def final_consumer_invoices_total
      total = invoice_scope.sum(:total_factura)
      total + invoice_notes_adjustment
    end

    def income_receipts_total
      RecibosIngreso
        .where(forma_pago: PAYMENT_METHODS, estado: true)
        .where(fecha_equivalente: closing_day_range)
        .sum(:total)
    end

    def invoices_by_payment_method
      result = empty_payment_methods
      invoice_scope.group(:forma_pago).sum(:total_factura).each do |payment_method, total|
        result[payment_method_key(payment_method)] = money(total)
      end
      invoice_notes_adjustment_by_payment_method.each do |payment_method, total|
        key = payment_method_key(payment_method)
        result[key] = money(result[key] + total)
      end
      result
    end

    def receipts_by_payment_method
      result = empty_payment_methods
      RecibosIngreso
        .where(forma_pago: PAYMENT_METHODS, estado: true)
        .where(fecha_equivalente: closing_day_range)
        .group(:forma_pago)
        .sum(:total)
        .each do |payment_method, total|
          result[payment_method_key(payment_method)] = money(total)
        end
      result
    end

    def invoice_documents
      invoice_scope.order('id ASC').map do |invoice|
        {
          id: invoice.id,
          numero_factura: invoice.numero_factura,
          numero_comprobante: invoice.numero_comprobante,
          forma_pago: invoice.forma_pago,
          total: decimal_string(invoice.total_factura),
          fecha_equivalente: invoice.fecha_equivalente,
          fecha_completada: invoice.fecha_completada
        }
      end
    end

    def receipt_documents
      RecibosIngreso
        .where(forma_pago: PAYMENT_METHODS, estado: true)
        .where(fecha_equivalente: closing_day_range)
        .order('id ASC')
        .map do |receipt|
          {
            id: receipt.id,
            numero_recibo: receipt.numero_recibo,
            forma_pago: receipt.forma_pago,
            total: decimal_string(receipt.total),
            fecha_equivalente: receipt.fecha_equivalente
          }
        end
    end

    def payment_methods_summary(invoice_breakdown, receipt_breakdown)
      empty_payment_methods.keys.each_with_object({}) do |key, result|
        result[key] = decimal_string(invoice_breakdown[key] + receipt_breakdown[key])
      end
    end

    def format_payment_methods(payment_methods)
      payment_methods.transform_values { |value| decimal_string(value) }
    end

    def invoice_scope
      scope = CabeceraFactura
        .where(forma_pago: PAYMENT_METHODS, estado: true)
        .where(fecha_equivalente: closing_day_range)
        .where("LOWER(tipo) = 'venta'")
        .where("LOWER(condicion) = 'contado'")
    end

    def invoice_notes_adjustment
      scope = FacturaAplicada.joins(:cabecera_factura, :tipo_factura)
        .where(cabecera_facturas: { forma_pago: PAYMENT_METHODS, estado: true })
        .where(cabecera_facturas: { fecha_equivalente: closing_day_range })
        .where("LOWER(cabecera_facturas.tipo) = 'venta'")
        .where("LOWER(cabecera_facturas.condicion) = 'contado'")
        .where(tipo_facturas: { key: ['nota_de_credito', 'nota_de_debito'] })

      scope.sum("CASE WHEN tipo_facturas.key = 'nota_de_debito' THEN facturas_aplicadas.total ELSE -facturas_aplicadas.total END")
    end

    def invoice_notes_adjustment_by_payment_method
      scope = FacturaAplicada.joins(:cabecera_factura, :tipo_factura)
        .where(cabecera_facturas: { forma_pago: PAYMENT_METHODS, estado: true })
        .where(cabecera_facturas: { fecha_equivalente: closing_day_range })
        .where("LOWER(cabecera_facturas.tipo) = 'venta'")
        .where("LOWER(cabecera_facturas.condicion) = 'contado'")
        .where(tipo_facturas: { key: ['nota_de_credito', 'nota_de_debito'] })

      scope.group("cabecera_facturas.forma_pago")
        .sum("CASE WHEN tipo_facturas.key = 'nota_de_debito' THEN facturas_aplicadas.total ELSE -facturas_aplicadas.total END")
    end

    def invoice_criteria
      'venta_contado_fecha_equivalente'
    end

    def empty_payment_methods
      {
        cash: BigDecimal('0'),
        check: BigDecimal('0'),
        card: BigDecimal('0'),
        bank_transfer: BigDecimal('0')
      }
    end

    def payment_method_key(payment_method)
      case payment_method.to_s.downcase
      when 'efectivo' then :cash
      when 'cheque' then :check
      when 'tarjeta' then :card
      when 'transferencia' then :bank_transfer
      else :other
      end
    end

    def money(value)
      BigDecimal(value.to_s.presence || '0').round(2)
    end

    def decimal_string(value)
      format('%.2f', money(value))
    end

    def closing_day_range
      @closing_day_range ||= @closing_date.beginning_of_day..@closing_date.end_of_day
    end
  end
end
