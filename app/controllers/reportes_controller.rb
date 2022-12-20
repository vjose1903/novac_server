class ReportesController < ApplicationController

  def getReportes

    tipo_reporte = params["tipo_reporte"]
    tipo         = tipo_reporte
    tipo_tabla   = 'normal'

    muestra_sub_titulo = ['inventario','recibos','ventas_productos','suplidor_prod','cuentas_con_pagos', 'notas', 'ventas_cliente']
    muestra_sub_titulo.push("cuentas_cobrar") if tipo_reporte == "cuentas_cobrar" && params["tipo"] == '1'

    if tipo_reporte == 'ventas' || tipo_reporte == 'ventas_cliente'
      # ------------------- REPORTE DE VENTAS --------------------
      body   = Reporte.get_ventas(params)

      titulo = "Reporte de ventas #{ params["tipo"] == TipoReporteVentas.ventas_hoy ? 'diarias' : "desde #{formatearFecha(params["desde"], TipoFecha.sin_hora)} hasta #{formatearFecha(params["hasta"], TipoFecha.sin_hora)}" }"

      titulo = "Reporte de ventas por cliente" if tipo_reporte == 'ventas_cliente'

    elsif tipo_reporte == 'cuentas_cobrar'
      # ------------------- REPORTE DE CUENTAS POR COBRAR --------------------
      body   = Reporte.get_cuentas_cobrar(params)
      titulo = "Reporte de cuentas por cobrar #{ params["tipo"] == '1' ? 'por cliente' : '' } #{ params["tipo"] == '1' ? '' : params["tipo"] == '2' ? '- DETALLADO -' : '- AGRUPADO -' }"

      tipo   = 'cxc'               if params["tipo"] == '1'
      tipo   = 'cxc_ant_detallado' if params["tipo"] == '2'
      tipo   = 'cxc_ant_agrupado'  if params["tipo"] != '2' && params["tipo"] != '1'


    elsif tipo_reporte == 'inventario'
      # ------------------- REPORTE DE INVENTARIO --------------------
      body   = Reporte.get_inventario(params)
      titulo = 'Reporte de inventario'

    elsif tipo_reporte == 'recibos'
      # ------------------- REPORTE DE RECIBOS --------------------
      body   = Reporte.get_recibos(params)
      titulo = 'Reporte de Recibos de ingreso'

    elsif tipo_reporte == 'ventas_productos'
      # ------------------- REPORTE DE VENTAS POR PRODUCTO --------------------
      body       = Reporte.get_ventas_por_producto(params)
      titulo     = 'Reporte de ventas por producto'
      tipo       = 'ventas_prod'
      tipo_tabla = 'agrupado'

    elsif tipo_reporte == 'suplidor_prod'
      # ------------------- REPORTE DE VENTAS POR PRODUCTO --------------------
      body   = Reporte.get_suplidores_por_producto(params)
      titulo = 'Reporte de suplidores por producto'

    elsif tipo_reporte == 'cuentas_con_pagos'
      # ------------------- REPORTE DE CUENTAS POR COBRAR CLIENTES CON SUS PAGOS --------------------
      body       = Reporte.get_cuentas_con_pagos(params)
      titulo     = 'Reporte de facturas a crédito con sus pagos'
      tipo_tabla = 'agrupado'

    elsif tipo_reporte == 'notas'
      # ------------------- REPORTE DE NOTAS --------------------
      body            = Reporte.get_notas(params)
      tipo_de_factura = TipoFactura.find_by_id(params['tipo_factura_id'])

      tipo_nota       = tipo_de_factura.descripcion == TiposFacturasDescripcion.nota_de_credito  ? 'Crédito' : tipo_de_factura.descripcion == TiposFacturasDescripcion.nota_de_debito ? 'Débito' : 'Crédito y Débito'
      titulo          = "Reporte de notas de #{tipo_nota}"

    end

    mostrar_sub_titulo = {
      bool: muestra_sub_titulo.any? { |item| [tipo_reporte].include? item },
      sub_t: body[:sub_t]
    }

    respuesta = Reporte.estructura_reporte(titulo, tipo, body[:body], body[:totalizacion], mostrar_sub_titulo, tipo_tabla)
    my_print_log("------------ TERMINO ------------".red)

    render json: respuesta, status: :ok
  end
end