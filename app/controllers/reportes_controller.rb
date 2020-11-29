class ReportesController < ApplicationController

    def getVentas
        ventas = Reporte.get_ventas(params)
        titulo = "Reporte de ventas #{ params["tipo"] == '1' ? 'diarias' : "desde #{formatearFecha(params["desde"], 1)} hasta #{formatearFecha(params["hasta"], 1)}" }"

        mostrar_total={
            bool: true,
            total: ventas[:total]
        }
        render json: Reporte.estructura_reporte(titulo ,'ventas', ventas[:body], mostrar_total, current_user)
    end

    def getCuentasPagar
        ventas = Reporte.get_ventas(params)
        titulo = "Reporte de ventas #{ params["tipo"] == '1' ? 'diarias' : "desde #{formatearFecha(params["desde"], 1)} hasta #{formatearFecha(params["hasta"], 1)}" }"

        mostrar_total={
            bool: true,
            total: ventas[:total]
        }
        render json: Reporte.estructura_reporte(titulo ,'ventas', ventas[:body], mostrar_total, current_user)
    end

    def getCuentasCobrar
        cuentas = Reporte.get_cuentas_cobrar(params)
        # titulo = "Reporte de cuentas #{ params["tipo"] == '1' ? 'diarias' : "desde #{formatearFecha(params["desde"], 1)} hasta #{formatearFecha(params["hasta"], 1)}" }"

        # mostrar_total={
        #     bool: true,
        #     total: cuentas[:total]
        # }
        # render json: Reporte.estructura_reporte(titulo ,'cuentas', ventas[:body], mostrar_total, current_user)
        render json: cuentas
    end

end