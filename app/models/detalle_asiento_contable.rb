class DetalleAsientoContable < ApplicationRecord
  belongs_to :cabeza_asiento_contable

  belongs_to :cuenta_contable_auxiliar,  class_name: 'CuentaContable'
  belongs_to :cuenta_contable_control,   class_name: 'CuentaContable'

  validates :valor_debito,  numericality: true, allow_nil: true, allow_blank: true
  validates :valor_credito, numericality: true, allow_nil: true, allow_blank: true

  def otras_validaciones(params)
    cuenta_auxiliar = self.cuenta_contable_auxiliar

    unless ( self.valor_debito.present? && self.valor_credito.present? ) && ( self.valor_debito > 0 || self.valor_credito > 0 )
      self.errors.add(:base, "Debe de especificar el monto para la cuenta: #{cuenta_auxiliar.descripcion}.")
    end

    if self.cuenta_contable_auxiliar.is_control
      self.errors.add(:base, "La cuenta: #{cuenta_auxiliar.descripcion}, es control, debe de seleccionar una cuenta auxiliar.")
    end
  end

  # ============================================================================================================================================

  def self.create_update(params, padre, is_save=false)
  res = Response.new

  detalle_asiento_contable                                = DetalleAsientoContable.where(:id => params[:id]).first_or_create

  detalle_asiento_contable.valor_debito                   = params[:valor_debito]
  detalle_asiento_contable.valor_credito                  = params[:valor_credito]
  detalle_asiento_contable.cuenta_contable_auxiliar_id    = params[:cuenta_contable_auxiliar_id]
  detalle_asiento_contable.cuenta_contable_control_id     = detalle_asiento_contable.cuenta_contable_auxiliar.cuenta_control

  detalle_asiento_contable.valid?
  detalle_asiento_contable.otras_validaciones(params)

  detalle_asiento_contable.errors.delete(:cabeza_asiento_contable) if !is_save

  if detalle_asiento_contable.errors.empty? && (!is_save || (is_save && detalle_asiento_contable.save!))
    res.set_data(detalle_asiento_contable)
  else
    res.add_msgs(detalle_asiento_contable.errors.to_a)
    res.set_status(HTTP_STATUS_CODE[:conflict])
  end

  return res
end

# ============================================================================================================================================

def self.validar_e_inicializar(items, grupo_cuenta, save)
  res_valid   = Response.new
  array_valid = []

  items.each do |item|
    res_temp  = self.create_update(item, grupo_cuenta, !item[:id].nil?)

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
