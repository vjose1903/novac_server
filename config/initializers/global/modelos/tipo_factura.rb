module TipoFacturaManagement
  def self.get_by_key(key)
    TipoFactura.find_by(:key => key)
  end

  def self.get_by_key_anf_serie(key, serie)
    TipoFactura.find_by(:key => key, :serie => serie)
  end
end