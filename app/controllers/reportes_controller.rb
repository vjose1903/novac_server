class ReportesController < ApplicationController

  def getReportes

    tipo_reporte = params[:tipo_reporte]
    tipo         = params[:tipo]
    tipo_tabla   = 'normal'

    muestra_sub_titulo = ['inventario','ventas_productos','suplidor_prod','cuentas_con_pagos', 'notas', 'ventas_cliente', 'movimientos_vehiculo']
    muestra_sub_titulo.push("cxc") if tipo_reporte == "cuentas_cobrar" && params[:tipo] == '1'


    if  tipo_reporte == 'ventas_rango' || tipo_reporte == 'ventas_diarias' || tipo_reporte == 'ventas_cliente'
      # ------------------- REPORTE DE VENTAS --------------------
      body           = Reporte.get_ventas(params)

      titulo         = "Reporte de ventas #{ params[:tipo] == TipoReporteVentas.ventas_hoy ? 'diarias' : "desde #{formatearFecha(params[:desde], TipoFecha.sin_hora)} hasta #{formatearFecha(params[:hasta], TipoFecha.sin_hora)}" }"
      titulo         = "Reporte de ventas por cliente" if tipo_reporte == 'ventas_cliente'

      tipo_reporte   = "#{tipo_reporte}_agrupado" if tipo == 'agrupado'

    elsif tipo_reporte == 'cuentas_cobrar'
      # ------------------- REPORTE DE CUENTAS POR COBRAR --------------------
      body   = Reporte.get_cuentas_cobrar(params)
      titulo = "Reporte de cuentas por cobrar #{ params[:tipo] == Report::CxC.por_cliente ? 'por cliente' : '' } #{ params[:tipo] == Report::CxC.por_cliente ? '' : params[:tipo] == Report::CxC.detallado ? '- DETALLADO -' : '- AGRUPADO -' }"

      tipo_reporte   = 'cxc'               if params[:tipo] == Report::CxC.por_cliente
      tipo_reporte   = 'cxc_ant_detallado' if params[:tipo] == Report::CxC.detallado
      tipo_reporte   = 'cxc_ant_agrupado'  if params[:tipo] == Report::CxC.agrupado

    elsif tipo_reporte == 'cuentas_pagar'
      # ------------------- REPORTE DE CUENTAS POR PAGAR --------------------
      body   = Reporte.get_cuentas_pagar(params)
      titulo = "Reporte de cuentas por pagar #{ params[:tipo] == Report::CxP.por_suplidor ? 'por suplidor' : '' } #{ params[:tipo] == Report::CxP.por_suplidor ? '' : params[:tipo] == Report::CxP.detallado ? '- DETALLADO -' : '- AGRUPADO -' }"

      tipo_reporte   = 'cxp'               if params[:tipo] == Report::CxP.por_suplidor
      tipo_reporte   = 'cxp_ant_detallado' if params[:tipo] == Report::CxP.detallado
      tipo_reporte   = 'cxp_ant_agrupado'  if params[:tipo] == Report::CxP.agrupado

    elsif tipo_reporte == 'movimientos_vehiculo'
      # ------------------- REPORTE DE MOVIMIENTOS POR VEHICULO --------------------
      body       = Reporte.get_movimientos_vehiculo(params)
      titulo     = 'Reporte de Movimientos por camión'

    elsif tipo_reporte == 'inventario'
      # ------------------- REPORTE DE INVENTARIO --------------------
      body   = Reporte.get_inventario(params)
      titulo = 'Reporte de inventario'

    elsif tipo_reporte == 'recibos'
      # ------------------- REPORTE DE RECIBOS --------------------
      body   = Reporte.get_recibos(params)
      titulo = 'Reporte de Recibos de ingreso'

      tipo_reporte   = "#{tipo_reporte}_agrupado" if tipo == 'agrupado'

    elsif tipo_reporte == 'pago_facturas'
      # ------------------- REPORTE DE PAGO DE FACTURAS --------------------
      body   = Reporte.get_pagos(params)
      titulo = 'Reporte de Pago de Facturas'

      tipo_reporte   = "#{tipo_reporte}_agrupado" if tipo == 'agrupado'

    elsif tipo_reporte == 'ventas_productos'
      # ------------------- REPORTE DE VENTAS POR PRODUCTO --------------------
      body               = Reporte.get_ventas_por_producto(params)
      titulo             = 'Reporte de ventas por producto'
      tipo_tabla         = 'agrupado'

    elsif tipo_reporte == 'suplidor_prod'
      # ------------------- REPORTE DE VENTAS POR PRODUCTO --------------------
      body     = Reporte.get_suplidores_por_producto(params)
      titulo   = 'Reporte de suplidores por producto'

    elsif tipo_reporte == 'cuentas_con_pagos'
      # ------------------- REPORTE DE CUENTAS POR COBRAR CLIENTES CON SUS PAGOS --------------------
      body       = Reporte.get_cuentas_con_pagos(params)
      titulo     = 'Reporte de facturas a crédito con sus pagos'
      tipo_tabla = 'agrupado'

    elsif tipo_reporte == 'notas'
      # ------------------- REPORTE DE NOTAS --------------------
      body            = Reporte.get_notas(params)
      tipo_de_factura = TipoFactura.find_by_id(params['tipo_factura_id'])

      tipo_nota       = tipo_de_factura.nil? ? 'Crédito y Débito' : tipo_de_factura.descripcion == TiposFacturasDescripcion.nota_de_credito  ? 'Crédito' : 'Débito'
      titulo          = "Reporte de notas de #{tipo_nota}"

    end

    mostrar_sub_titulo = {
      bool: muestra_sub_titulo.any? { |item| [tipo_reporte].include? item },
      sub_t: body[:sub_t]
    }

    estructura_reporte = { titulo: titulo, tipo_reporte: tipo_reporte, content: body[:body], totalizacion: body[:totalizacion], sub_titulo: mostrar_sub_titulo, tipo_tabla: tipo_tabla,  }.with_indifferent_access
    respuesta          = Reporte.estructura_reporte(estructura_reporte)

    render json: respuesta, status: :ok
  end
end