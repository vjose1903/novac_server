module NivelesGrupos
  MAYOR       = 1
  CONTROL     = 2
  AUXILIAR    = 3
  SUBAUXILIAR = 4


  def self.mayor
    return MAYOR
  end

  def self.control
    return CONTROL
  end

  def self.auxiliar
    return AUXILIAR
  end

  def self.sub_auxiliar
    return SUBAUXILIAR
  end
end

module OrigenGrupo
  DEBITO      = "D"
  CREDITO     = "C"

  def self.debito
    return DEBITO
  end

  def self.credito
    return CREDITO
  end

	def self.get_label(origen)
		return origen == self.debito ? "Débito" : "Crédito"
	end
end


module TipoGrupo
  REAL        = "R"
  NOMINAL     = "N"

  def self.real
    return REAL
  end

  def self.nominal
    return NOMINAL
  end

	def self.get_label(tipo)
		return tipo == self.real ? "Real" : "Nominal"
	end
end