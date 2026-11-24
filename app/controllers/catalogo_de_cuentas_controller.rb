class CatalogoDeCuentasController < ApplicationController

  def getCatalogoDeCuentas
    grupos = GrupoCuenta.where(estado: true).order('id ASC').includes(:cuentas_contables)
    catalogo = CatalogoCuenta::GrupoCuenta.iterator(grupos)
    Response.new(params, nil, catalogo, nil).send_response self
  end

  def getDefaultStructure
    Response.new(params, nil, G_CATALOGO_DEFAULT, nil).send_response self
  end

  def createCatalogoDeCuentasDefault
		resultado = CatalogoDeCuentas.create_catalogo_de_cuentas_default
		resultado.send_response self
  end

end
