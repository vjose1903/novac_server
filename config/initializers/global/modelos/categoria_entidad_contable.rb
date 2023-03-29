module CatEntidadContable

  TIPO = {
    cliente:   "cliente",
    suplidor:  "suplidor",
    user:      "user"
  }.with_indifferent_access

  TIPOS = {
    cliente:   "clientes",
    suplidor:  "suplidores",
    user:      "usuarios"
  }.with_indifferent_access

  def self.cliente
    return TIPO[:cliente]
  end

  def self.suplidor
    return TIPO[:suplidor]
  end

  def self.user
    return TIPO[:user]
  end

  def self.get_tipo(tipo)
    return TIPO[:"#{tipo}"]
  end

  def self.get_tipo_plural(tipo)
    return TIPOS[:"#{tipo}"]
  end

    # ============================================================================================================================================

    def self.createCuenta(cuenta_control, descripcion, is_control)
      res = Response.new
      cuenta_contable              = ConfiguracionEntidadCuenta.molde_cuenta(cuenta_control, descripcion, is_control)

      temp_cuenta_contable         = CuentaContable.create_update_cuenta_contable(cuenta_contable, nil, true)

      if temp_cuenta_contable.status_valid
        cuenta_contable            = temp_cuenta_contable.get_data.as_json.with_indifferent_access
        res.set_data(cuenta_contable)
      else
        res.add_msgs(temp_cuenta_contable.get_msgs)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res
    end

end


module TipoAgrupacionContable
  TIPO = {
    SIN_CUENTA:     "sin_cuenta",
    CATEGORIA:      "categoria",
    SUB_CATEGORIA:  "sub_categoria",
    INDIVIDUAL:     "individual"
  }.with_indifferent_access

  def self.sin_cuenta
    return TIPO[:SIN_CUENTA]
  end

  def self.categoria
    return TIPO[:CATEGORIA]
  end

  def self.sub_categoria
    return TIPO[:SUB_CATEGORIA]
  end

  def self.individual
    return TIPO[:INDIVIDUAL]
  end

  def self.get_tipo(tipo)
    return TIPO[:"#{tipo}"]
  end
end