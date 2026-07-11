module Reportes
  module Main
    extend self

    def estructura_reporte(arg)
      Reportes::Shared::CommonHelpers.estructura_reporte(arg)
    end

    def buscar_suplidor(supli, max_lengt = 0)
      Reportes::Shared::CommonHelpers.buscar_suplidor(supli, max_lengt)
    end

    def buscar_cliente(factura, max_lengt, retornar)
      Reportes::Shared::CommonHelpers.buscar_cliente(factura, max_lengt, retornar)
    end

    def get_cuentas_cobrar(params)
      Reportes::Clientes::CuentasCobrar.call(params)
    end

    def sustituirMonto(detalle, columnas_antiguedad = nil)
      Reportes::Clientes::CuentasCobrar.sustituir_monto(detalle, columnas_antiguedad)
    end

    def antiguedad_bucket_definitions
      Reportes::Clientes::CuentasCobrar.antiguedad_bucket_definitions
    end

    def antiguedad_bucket_keys
      Reportes::Clientes::CuentasCobrar.antiguedad_bucket_keys
    end

    def parse_antiguedad_columns(params)
      Reportes::Clientes::CuentasCobrar.parse_antiguedad_columns(params)
    end

    def normalize_antiguedad_bucket(value)
      Reportes::Clientes::CuentasCobrar.normalize_antiguedad_bucket(value)
    end

    def antiguedad_bucket_selects(columnas_antiguedad, tipo)
      Reportes::Clientes::CuentasCobrar.antiguedad_bucket_selects(columnas_antiguedad, tipo)
    end

    def build_antiguedad_filter_where(columnas_antiguedad)
      Reportes::Clientes::CuentasCobrar.build_antiguedad_filter_where(columnas_antiguedad)
    end

    def calcularCantidades(articulos)
      Reportes::Shared::CommonHelpers.calcular_cantidades(articulos)
    end

    def get_inventario(params)
      Reportes::Inventario::Inventario.call(params)
    end

    def get_notas(params)
      Reportes::Notas::Notas.call(params)
    end

    def get_recibos(params)
      Reportes::Recibos::Recibos.call(params)
    end

    def sum_by_day_recibos(records)
      Reportes::Recibos::Recibos.sum_by_day(records)
    end

    def get_suplidores_por_producto(params)
      Reportes::Suplidores::Productos.call(params)
    end

    def get_movimientos_vehiculo(params)
      Reportes::Facturas::MovimientosVehiculo.call(params)
    end

    def get_cuentas_con_pagos(params)
      Reportes::Facturas::CuentasConPagos.call(params)
    end

    def get_ventas_por_producto(params)
      Reportes::Facturas::VentasPorProducto.call(params)
    end

    def calcular_cantidad_proporcional(detalle)
      Reportes::Facturas::VentasPorProducto.calcular_cantidad_proporcional(detalle)
    end

    def get_ventas(params)
      Reportes::Facturas::Ventas.call(params)
    end

    def sum_by_day_ventas(records)
      Reportes::Facturas::Ventas.sum_by_day(records)
    end

    def get_balance_cliente_historico(params)
      Reportes::Clientes::BalanceHistorico.call(params)
    end
  end
end
