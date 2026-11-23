

module SerieFactura
  ELECTRONICA = 'electronica'
  NORMAL      = 'normal'
  ALL         = 'all'
  NO_         = 0

  def self.electronica
    return ELECTRONICA
  end

  def self.normal
    return NORMAL
  end

  def self.all
    return ALL
  end

  def self.no
    return NO_
  end
end


module TiposFacturasDescripcion
  FACTURA_SIN_COMPROBANTE                = 'Factura sin comprobante'
  FACTURA_CON_VALOR_FISCAL               = 'Factura con valor fiscal'
  FACTURA_DE_CONSUMO                     = 'Factura de consumo'
  NOTA_DE_DEBITO                         = 'Nota de debito'
  NOTA_DE_CREDITO                        = 'Nota de credito'
  COMPROBANTE_DE_COMPRAS                 = 'Comprobante de compras'
  REGISTRO_DE_UNICO_INGRESO              = 'Registro de unico ingreso'
  COMPROBANTE_PARA_GASTOS_MENORES        = 'Comprobante para gastos menores'
  COMPROBANTE_DE_REGIMEN_ESPECIALES      = 'Comprobante de regimen especiales'
  COMPROBANTE_GUBERNAMENTAL              = 'Comprobante gubernamental'
  COMPROBANTE_PARA_EXPORTACIONES         = 'Comprobante para exportaciones'
  COMPROBANTES_PARA_PAGO_AL_EXTERIOR     = 'Comprobantes para pago al exterior'
  VENTA_CONTADO                          = 'Venta Contado'
  COMPRA                                 = 'Compra'
  CONDUCE                                = 'Conduce'
  PRODUCCION                             = 'Produccion'
  RECIBO_INGRESO                         = 'Recibo_ingreso'
  VENTA_CREDITO                          = 'Venta Credito'
  PRE_VENTA                              = 'pre_venta'
  COTIZACION                             = 'cotizacion'
  PAGO_FACTURA                           = 'pago factura'

  def self.factura_sin_comprobante
    return FACTURA_SIN_COMPROBANTE
  end

  def self.factura_con_valor_fiscal
    return FACTURA_CON_VALOR_FISCAL
  end

  def self.factura_de_consumo
    return FACTURA_DE_CONSUMO
  end

  def self.nota_de_debito
    return NOTA_DE_DEBITO
  end

  def self.nota_de_credito
    return NOTA_DE_CREDITO
  end

  def self.comprobante_de_compras
    return COMPROBANTE_DE_COMPRAS
  end

  def self.registro_de_unico_ingreso
    return REGISTRO_DE_UNICO_INGRESO
  end

  def self.comprobante_para_gastos_menores
    return COMPROBANTE_PARA_GASTOS_MENORES
  end

  def self.comprobante_de_regimen_especiales
    return COMPROBANTE_DE_REGIMEN_ESPECIALES
  end

  def self.comprobante_gubernamental
    return COMPROBANTE_GUBERNAMENTAL
  end

  def self.comprobante_para_exportaciones
    return COMPROBANTE_PARA_EXPORTACIONES
  end

  def self.comprobantes_para_pago_al_exterior
    return COMPROBANTES_PARA_PAGO_AL_EXTERIOR
  end

  def self.venta_contado
    return VENTA_CONTADO
  end

  def self.compra
    return COMPRA
  end

  def self.conduce
    return CONDUCE
  end

  def self.produccion
    return PRODUCCION
  end

  def self.recibo_ingreso
    return RECIBO_INGRESO
  end

  def self.venta_credito
    return VENTA_CREDITO
  end

  def self.pre_venta
    return PRE_VENTA
  end

  def self.cotizacion
    return COTIZACION
  end

  def self.pago_factura
    return PAGO_FACTURA
  end

end


module TiposFacturasKey
  FACTURA_SIN_COMPROBANTE              = 'factura_sin_comprobante'
  FACTURA_CON_VALOR_FISCAL             = 'factura_de_credito_fiscal'
  FACTURA_DE_CONSUMO                   = 'factura_de_consumo'
  NOTA_DE_DEBITO                       = 'nota_de_debito'
  NOTA_DE_CREDITO                      = 'nota_de_credito'
  COMPROBANTE_DE_COMPRAS               = 'comprobante_compras'
  REGISTRO_DE_UNICO_INGRESO            = 'registro_unico_ingreso'
  COMPROBANTE_PARA_GASTOS_MENORES      = 'gastos_menores'
  COMPROBANTE_DE_REGIMEN_ESPECIALES    = 'regimenes_especiales'
  COMPROBANTE_GUBERNAMENTAL            = 'gubernamental'
  COMPROBANTE_PARA_EXPORTACIONES       = 'comprobante_de_exportaciones'
  COMPROBANTES_PARA_PAGO_AL_EXTERIOR   = 'comprobante_pagos_al_exterior'
  VENTA_CONTADO                        = 'venta_contado'
  COMPRA                               = 'compra'
  CONDUCE                              = 'conduce'
  PRODUCCION                           = 'produccion'
  RECIBO_INGRESO                       = 'recibo_ingreso'
  VENTA_CREDITO                        = 'venta_credito'
  PRE_VENTA                            = 'pre_venta'
  COTIZACION                           = 'cotizacion'
  PAGO_FACTURA                         = 'pago_factura'

  def self.factura_sin_comprobante
    return FACTURA_SIN_COMPROBANTE
  end

  def self.factura_con_valor_fiscal
    return FACTURA_CON_VALOR_FISCAL
  end

  def self.factura_de_consumo
    return FACTURA_DE_CONSUMO
  end

  def self.nota_de_debito
    return NOTA_DE_DEBITO
  end

  def self.nota_de_credito
    return NOTA_DE_CREDITO
  end

  def self.comprobante_de_compras
    return COMPROBANTE_DE_COMPRAS
  end

  def self.registro_de_unico_ingreso
    return REGISTRO_DE_UNICO_INGRESO
  end

  def self.comprobante_para_gastos_menores
    return COMPROBANTE_PARA_GASTOS_MENORES
  end

  def self.comprobante_de_regimen_especiales
    return COMPROBANTE_DE_REGIMEN_ESPECIALES
  end

  def self.comprobante_gubernamental
    return COMPROBANTE_GUBERNAMENTAL
  end

  def self.comprobante_para_exportaciones
    return COMPROBANTE_PARA_EXPORTACIONES
  end

  def self.comprobantes_para_pago_al_exterior
    return COMPROBANTES_PARA_PAGO_AL_EXTERIOR
  end

  def self.venta_contado
    return VENTA_CONTADO
  end

  def self.compra
    return COMPRA
  end

  def self.conduce
    return CONDUCE
  end

  def self.produccion
    return PRODUCCION
  end

  def self.recibo_ingreso
    return RECIBO_INGRESO
  end

  def self.venta_credito
    return VENTA_CREDITO
  end

  def self.pre_venta
    return PRE_VENTA
  end

  def self.cotizacion
    return COTIZACION
  end

  def self.pago_factura
    return PAGO_FACTURA
  end
end