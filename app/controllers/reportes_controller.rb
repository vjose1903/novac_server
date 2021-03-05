class ReportesController < ApplicationController



    def getReportes
        tipo_reporte = params["tipo_reporte"]
        tipo = ''
        tipo_tabla = 'normal'
        muestra_sub_titulo = ['inventario','recibos','ventas_productos','suplidor_prod']

        muestra_sub_titulo.push("cuentas_cobrar") if tipo_reporte == "cuentas_cobrar" && params["tipo"] == '2'

        if tipo_reporte==='ventas'
            # ------------------- REPORTE DE VENTAS --------------------
            body = Reporte.get_ventas(params)
            titulo = "Reporte de ventas #{ params["tipo"] == '1' ? 'diarias' : "desde #{formatearFecha(params["desde"], 1)} hasta #{formatearFecha(params["hasta"], 1)}" }"
            tipo = 'ventas'
            
            
        elsif tipo_reporte==='cuentas_cobrar'
            # ------------------- REPORTE DE CUENTAS POR COBRAR --------------------
            body = Reporte.get_cuentas_cobrar(params)
            titulo = "Reporte de cuentas por cobrar #{ params["tipo"] == '2' ? 'por cliente' : '' }"
            if params["tipo"] == '2'
                tipo = 'cxc'
            else
                tipo = 'cxc_ant'
            end
            
        elsif tipo_reporte==='inventario'
            # ------------------- REPORTE DE INVENTARIO --------------------
            body = Reporte.get_inventario(params)
            titulo = "Reporte de inventario"
            tipo = 'inventario'

        elsif tipo_reporte==='recibos'
            # ------------------- REPORTE DE RECIBOS --------------------
            body = Reporte.get_recibos(params)
            titulo = "Reporte de Recibos de ingreso"
            tipo = 'recibos'

        elsif tipo_reporte==='ventas_productos'
            # ------------------- REPORTE DE VENTAS POR PRODUCTO -------------------- 
            body = Reporte.get_ventas_por_producto(params)
            titulo = "Reporte de ventas por producto"
            tipo = 'ventas_prod'
            tipo_tabla = 'agrupado'
            
        elsif tipo_reporte==='suplidor_prod'
            # ------------------- REPORTE DE VENTAS POR PRODUCTO --------------------
            body = Reporte.get_suplidores_por_producto(params)
            titulo = "Reporte de suplidores por producto"
            tipo = 'suplidor_prod'
            
        end

        mostrar_sub_titulo = {
            bool: muestra_sub_titulo.any? { |i| [tipo_reporte].include? i },
            sub_t: body[:sub_t]
        }

        render json: Reporte.estructura_reporte(titulo , tipo, body[:body], body[:total], mostrar_sub_titulo, tipo_tabla, current_user)
    end

end