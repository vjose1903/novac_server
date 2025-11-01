class ReportesController < ApplicationController

  def getReportes

    tipo_reporte = params[:tipo_reporte]
    tipo         = params[:tipo]
    tipo_tabla   = 'normal'

    muestra_sub_titulo = ['inventario', 'ventas_productos', 'suplidor_prod', 'cuentas_con_pagos', 'notas', 'ventas_cliente', 'movimientos_vehiculo', 'recibos', 'recibos_agrupado', 'cxc', 'cxc_ant_detallado', 'cxc_ant_agrupado', 'cxp', 'cxp_ant_detallado', 'cxp_ant_agrupado', 'pago_facturas', 'pago_facturas_agrupado' ]


    if  tipo_reporte == 'ventas_rango' || tipo_reporte == 'ventas_diarias' || tipo_reporte == 'ventas_cliente'
      # ------------------- REPORTE DE VENTAS --------------------
      body           = Reporte.get_ventas(params)

      titulo         = "Ventas #{ params[:tipo] == TipoReporteVentas.ventas_hoy ? 'diarias' : "desde #{formatearFecha(params[:desde], TipoFecha.sin_hora)} hasta #{formatearFecha(params[:hasta], TipoFecha.sin_hora)}" }"
      titulo         = "Ventas por cliente" if tipo_reporte == 'ventas_cliente'

      tipo_reporte   = "#{tipo_reporte}_agrupado" if tipo == 'agrupado'

    elsif tipo_reporte == 'cuentas_cobrar'
      # ------------------- REPORTE DE CUENTAS POR COBRAR --------------------
      puts "params[:tipo] ==> #{params[:tipo]} ".light_green
      if params[:tipo] == Report::CxC.historico
        puts " "
        puts " "
        puts " "
        puts "ANDO AQUIII".yellow
        puts " "
        puts " "
        puts " "
        body   = Reporte.get_balance_cliente_historico(params)
        titulo = "Cuentas por cobrar por cliente histórico"
      else
        body   = Reporte.get_cuentas_cobrar(params)
        titulo = "Cuentas por cobrar #{ params[:tipo] == Report::CxC.por_cliente ? 'por cliente' : '' } #{ params[:tipo] == Report::CxC.por_cliente ? '' : params[:tipo] == Report::CxC.detallado ? '- DETALLADO -' : '- AGRUPADO -' }"
      end


      tipo_reporte   = 'cxc'               if params[:tipo] == Report::CxC.por_cliente
      tipo_reporte   = 'cxc_historico'     if params[:tipo] == Report::CxC.historico
      tipo_reporte   = 'cxc_ant_detallado' if params[:tipo] == Report::CxC.detallado
      tipo_reporte   = 'cxc_ant_agrupado'  if params[:tipo] == Report::CxC.agrupado

    elsif tipo_reporte == 'cuentas_pagar'
      # ------------------- REPORTE DE CUENTAS POR PAGAR --------------------
      body   = Reporte.get_cuentas_pagar(params)
      titulo = "Cuentas por pagar #{ params[:tipo] == Report::CxP.por_suplidor ? 'por suplidor' : '' } #{ params[:tipo] == Report::CxP.por_suplidor ? '' : params[:tipo] == Report::CxP.detallado ? '- DETALLADO -' : '- AGRUPADO -' }"

      tipo_reporte   = 'cxp'               if params[:tipo] == Report::CxP.por_suplidor
      tipo_reporte   = 'cxp_ant_detallado' if params[:tipo] == Report::CxP.detallado
      tipo_reporte   = 'cxp_ant_agrupado'  if params[:tipo] == Report::CxP.agrupado
      
    elsif tipo_reporte == 'cxc_historico'
      # ------------------- REPORTE DE CUENTAS POR COBRAR HISTORICO --------------------
      body   = Reporte.get_balance_cliente_historico(params)
      titulo = "Cuentas por cobrar histórico"

    elsif tipo_reporte == 'movimientos_vehiculo'
      # ------------------- REPORTE DE MOVIMIENTOS POR VEHICULO --------------------
      body       = Reporte.get_movimientos_vehiculo(params)
      titulo     = 'Movimientos por camión'

    elsif tipo_reporte == 'inventario'
      # ------------------- REPORTE DE INVENTARIO --------------------
      body   = Reporte.get_inventario(params)
      titulo = 'Inventario'

    elsif tipo_reporte == 'recibos'
      # ------------------- REPORTE DE RECIBOS --------------------
      body   = Reporte.get_recibos(params)
      titulo = "Recibos de ingreso #{params[:tipo] == Report::ReciboIngreso.detallado ? '- DETALLADO -' : '- AGRUPADO -'}"

      tipo_reporte   = "#{tipo_reporte}_agrupado" if tipo == Report::ReciboIngreso.agrupado

    elsif tipo_reporte == 'pago_facturas'
      # ------------------- REPORTE DE PAGO DE FACTURAS --------------------
      body   = Reporte.get_pagos(params)
      titulo = "Pago de Facturas - desde #{formatearFecha(params[:desde], TipoFecha.sin_hora)} hasta #{formatearFecha(params[:hasta], TipoFecha.sin_hora)}"

      tipo_reporte   = "#{tipo_reporte}_agrupado" if tipo == 'agrupado'

    elsif tipo_reporte == 'ventas_productos'
      # ------------------- REPORTE DE VENTAS POR PRODUCTO --------------------
      body               = Reporte.get_ventas_por_producto(params)
      titulo             = 'Ventas por producto'
      tipo_tabla         = 'agrupado'

    elsif tipo_reporte == 'suplidor_prod'
      # ------------------- REPORTE DE VENTAS POR PRODUCTO --------------------
      body     = Reporte.get_suplidores_por_producto(params)
      titulo   = 'Suplidores por producto'

    elsif tipo_reporte == 'cuentas_con_pagos'
      # ------------------- REPORTE DE CUENTAS POR COBRAR CLIENTES CON SUS PAGOS --------------------
      body       = Reporte.get_cuentas_con_pagos(params)
      titulo     = 'Facturas a crédito con sus pagos'
      tipo_tabla = 'agrupado'

    elsif tipo_reporte == 'notas'
      # ------------------- REPORTE DE NOTAS --------------------
      body            = Reporte.get_notas(params)
      tipo_de_factura = TipoFactura.find_by_id(params['tipo_factura_id'])

      tipo_nota       = tipo_de_factura.nil? ? 'Crédito y Débito' : tipo_de_factura.descripcion == TiposFacturasDescripcion.nota_de_credito  ? 'Crédito' : 'Débito'
      titulo          = "Notas de #{tipo_nota}"

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