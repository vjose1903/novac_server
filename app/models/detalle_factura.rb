class DetalleFactura < ApplicationRecord
  belongs_to :cabecera_factura
  belongs_to :articulo

  before_save :update_calcular_saco

  def update_calcular_saco
    self.calcular_saco = self.calcular_saco.nil? ? false : self.calcular_saco
  end

end
