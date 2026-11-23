class CatalogoDeCuentasController < ApplicationController

  def getCatalogoDeCuentas
  end

  def createCatalogoDeCuentasDefault
		resultado = CatalogoDeCuentas.create_catalogo_de_cuentas_default
		resultado.send_response self
  end

end
