class ReportesController < ApplicationController



    def getReportes
        tipo_reporte = params["tipo_reporte"]

        muestra_total=['ventas','cuentas_cobrar']
        muestra_sub_titulo=['inventario']
        tipo = ''

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
            
        end

        mostrar_total = {
            bool: muestra_total.any? { |i| [tipo_reporte].include? i },
            total: body[:total]
        }

        mostrar_sub_titulo = {
            bool: muestra_sub_titulo.any? { |i| [tipo_reporte].include? i },
            sub_t: body[:sub_t]
        }

        render json: Reporte.estructura_reporte(titulo , tipo, body[:body], mostrar_total, mostrar_sub_titulo, current_user)
    end


    # def getVentas
    #     ventas = Reporte.get_ventas(params) #     titulo = "Reporte de ventas #{ params["tipo"] == '1' ? 'diarias' : "desde #{formatearFecha(params["desde"], 1)} hasta #{formatearFecha(params["hasta"], 1)}" }"

    #     mostrar_total={
    #         bool: true,
    #         total: ventas[:total]
    #     }
    #     mostrar_sub_titulo={
    #         bool: false,
    #         arg: {}
    #     }
    #     render json: Reporte.estructura_reporte(titulo ,'ventas', ventas[:body], mostrar_total, mostrar_sub_titulo, current_user)
    # end
    
    # def getCuentasPagar
    #     ventas = Reporte.get_ventas(params)
    #     titulo = "Reporte de ventas #{ params["tipo"] == '1' ? 'diarias' : "desde #{formatearFecha(params["desde"], 1)} hasta #{formatearFecha(params["hasta"], 1)}" }"
        
    #     mostrar_total={
    #         bool: true,
    #         total: ventas[:total]
    #     }
    #     mostrar_sub_titulo={
    #         bool: false,
    #         arg: {}
    #     }
    #     render json: Reporte.estructura_reporte(titulo ,'ventas', ventas[:body], mostrar_total, mostrar_sub_titulo, current_user)
    # end
    
    # def getCuentasCobrar
    #     cuentas = Reporte.get_cuentas_cobrar(params)
    #     titulo = "Reporte de cuentas por cobrar"

    #     mostrar_total={
    #         bool: true,
    #         total: cuentas[:total]
    #     }

    #     mostrar_sub_titulo={
    #         bool: true,
    #         arg: ""
    #     }

    #     render json: Reporte.estructura_reporte(titulo ,'cuentas', cuentas[:body], mostrar_total, mostrar_sub_titulo, current_user)
    #     # render json: cuentas
    # end

end