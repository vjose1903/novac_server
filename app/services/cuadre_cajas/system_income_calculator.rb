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
      credit_invoices_total = credit_invoices_total()
      receipts_total = income_receipts_total
      invoice_breakdown = invoices_by_payment_method
      receipt_breakdown = receipts_by_payment_method

      {
        final_consumer_invoices_total: decimal_string(invoices_total),
        credit_invoices_total: decimal_string(credit_invoices_total),
        income_receipts_total: decimal_string(receipts_total),
        system_income_total: decimal_string(invoices_total + receipts_total),
        payment_methods: payment_methods_summary(invoice_breakdown, receipt_breakdown),
        invoice_payment_methods: format_payment_methods(invoice_breakdown),
        receipt_payment_methods: format_payment_methods(receipt_breakdown),
        invoices: invoice_documents,
        credit_invoices: credit_invoice_documents,
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
      total += external_card_invoice_payment_scope.sum(:monto)
      total + invoice_notes_adjustment
    end

    def income_receipts_total
      RecibosIngreso
        .where(estado: true)
        .where(fecha_equivalente: closing_day_range)
        .sum(:total)
    end

    def credit_invoices_total
      total = credit_invoice_scope.sum(:total_factura)
      total + credit_invoice_notes_adjustment
    end

    def invoices_by_payment_method
      result = empty_payment_methods
      invoice_payment_scope.group(:forma_pago).sum(:monto).each do |payment_method, total|
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
      receipt_payment_scope
        .group(:forma_pago)
        .sum(:monto)
        .each do |payment_method, total|
          result[payment_method_key(payment_method)] = money(total)
        end
      result
    end

    def invoice_documents
      invoice_payment_scope.order('metodo_de_pago.id ASC').map do |pago|
        invoice = pago.metodo_de_pago_able
        {
          id: invoice.id,
          numero_factura: invoice.numero_factura,
          numero_comprobante: invoice.numero_comprobante,
          forma_pago: pago.forma_pago,
          cliente_nombre: document_client_name(invoice),
          total: decimal_string(pago.monto),
          fecha_equivalente: invoice.fecha_equivalente,
          fecha_completada: invoice.fecha_completada
        }
      end
    end

    def receipt_documents
      receipt_payment_scope.order('metodo_de_pago.id ASC').map do |pago|
        receipt = pago.metodo_de_pago_able
          {
            id: receipt.id,
            numero_recibo: receipt.numero_recibo,
            forma_pago: pago.forma_pago,
            cliente_nombre: receipt.cliente&.nombre_completo,
            total: decimal_string(pago.monto),
            fecha_equivalente: receipt.fecha_equivalente
          }
        end
    end

    def credit_invoice_documents
      credit_invoice_scope.includes(:cliente).order('id ASC').map do |invoice|
        {
          id: invoice.id,
          numero_factura: invoice.numero_factura,
          numero_comprobante: invoice.numero_comprobante,
          forma_pago: invoice.forma_pago,
          cliente_nombre: document_client_name(invoice),
          total: decimal_string(invoice.total_factura),
          fecha_equivalente: invoice.fecha_equivalente
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
      CabeceraFactura
        .where(estado: true)
        .where(fecha_equivalente: closing_day_range)
        .where("LOWER(tipo) = 'venta'")
        .where("LOWER(condicion) = 'contado'")
        .where(non_external_invoice_condition)
    end

    def invoice_payment_scope
      MetodoDePago
        .joins('INNER JOIN cabecera_facturas ON cabecera_facturas.id = metodo_de_pago.metodo_de_pago_able_id')
        .where(metodo_de_pago_able_type: 'CabeceraFactura')
        .where(cabecera_facturas: { estado: true, fecha_equivalente: closing_day_range })
        .where("LOWER(cabecera_facturas.tipo) = 'venta'")
        .where("LOWER(cabecera_facturas.condicion) = 'contado'")
        .where(invoice_payment_inclusion_condition)
    end

    def external_card_invoice_payment_scope
      MetodoDePago
        .joins('INNER JOIN cabecera_facturas ON cabecera_facturas.id = metodo_de_pago.metodo_de_pago_able_id')
        .where(metodo_de_pago_able_type: 'CabeceraFactura')
        .where(cabecera_facturas: { estado: true, fecha_equivalente: closing_day_range })
        .where("LOWER(cabecera_facturas.tipo) = 'venta'")
        .where("LOWER(cabecera_facturas.condicion) = 'contado'")
        .where('COALESCE(cabecera_facturas.is_external, false) = true')
        .where("LOWER(metodo_de_pago.forma_pago) = 'tarjeta'")
    end

    def receipt_payment_scope
      MetodoDePago
        .joins('INNER JOIN recibos_ingresos ON recibos_ingresos.id = metodo_de_pago.metodo_de_pago_able_id')
        .where(metodo_de_pago_able_type: 'RecibosIngreso')
        .where(recibos_ingresos: { estado: true, fecha_equivalente: closing_day_range })
    end

    def credit_invoice_scope
      CabeceraFactura
        .where(estado: true)
        .where(fecha_equivalente: closing_day_range)
        .where("LOWER(tipo) = 'venta'")
        .where("LOWER(condicion) = 'crédito'")
        .where(non_external_invoice_condition)
    end

    def invoice_notes_adjustment
      scope = FacturaAplicada.joins(:cabecera_factura, :tipo_factura)
        .where(cabecera_facturas: { estado: true })
        .where(cabecera_facturas: { fecha_equivalente: closing_day_range })
        .where("LOWER(cabecera_facturas.tipo) = 'venta'")
        .where("LOWER(cabecera_facturas.condicion) = 'contado'")
        .where(non_external_invoice_condition)
        .where(tipo_facturas: { key: ['nota_de_credito', 'nota_de_debito'] })

      scope.sum("CASE WHEN tipo_facturas.key = 'nota_de_debito' THEN facturas_aplicadas.total ELSE -facturas_aplicadas.total END")
    end

    def invoice_notes_adjustment_by_payment_method
      FacturaAplicada
        .joins(:cabecera_factura, :tipo_factura)
        .joins("INNER JOIN metodo_de_pago ON metodo_de_pago.metodo_de_pago_able_type = 'CabeceraFactura' AND metodo_de_pago.metodo_de_pago_able_id = cabecera_facturas.id")
        .where(cabecera_facturas: { estado: true, fecha_equivalente: closing_day_range })
        .where("LOWER(cabecera_facturas.tipo) = 'venta'")
        .where("LOWER(cabecera_facturas.condicion) = 'contado'")
        .where(non_external_invoice_condition)
        .where(tipo_facturas: { key: ['nota_de_credito', 'nota_de_debito'] })
        .group('metodo_de_pago.forma_pago')
        .sum("(CASE WHEN tipo_facturas.key = 'nota_de_debito' THEN facturas_aplicadas.total ELSE -facturas_aplicadas.total END) * metodo_de_pago.monto / NULLIF(cabecera_facturas.total_factura, 0)")
    end

    def credit_invoice_notes_adjustment
      FacturaAplicada.joins(:cabecera_factura, :tipo_factura)
        .where(cabecera_facturas: { estado: true, fecha_equivalente: closing_day_range })
        .where("LOWER(cabecera_facturas.tipo) = 'venta'")
        .where("LOWER(cabecera_facturas.condicion) = 'crédito'")
        .where(non_external_invoice_condition)
        .where(tipo_facturas: { key: ['nota_de_credito', 'nota_de_debito'] })
        .sum("CASE WHEN tipo_facturas.key = 'nota_de_debito' THEN facturas_aplicadas.total ELSE -facturas_aplicadas.total END")
    end

    def non_external_invoice_condition
      'COALESCE(cabecera_facturas.is_external, false) = false'
    end

    def invoice_payment_inclusion_condition
      "(#{non_external_invoice_condition} OR (COALESCE(cabecera_facturas.is_external, false) = true AND LOWER(metodo_de_pago.forma_pago) = 'tarjeta'))"
    end

    def invoice_criteria
      'venta_contado_fecha_equivalente; credit_invoices_total es informativo y no afecta el cuadre'
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

    def document_client_name(document)
      document.cliente&.nombre_completo.presence || document.NoCliente_nombre.presence || 'Cliente contado'
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
