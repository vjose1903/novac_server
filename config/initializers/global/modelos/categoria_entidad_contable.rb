module CategoriaEntidadContable

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