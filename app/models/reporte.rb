class Reporte < ApplicationRecord
  class << self
    def estructura_reporte(arg)
      Reportes::Main.estructura_reporte(arg)
    end

    def buscar_suplidor(supli, max_lengt = 0)
      Reportes::Main.buscar_suplidor(supli, max_lengt)
    end

    def buscar_cliente(factura, max_lengt, retornar)
      Reportes::Main.buscar_cliente(factura, max_lengt, retornar)
    end

    def get_cuentas_cobrar(params)
      Reportes::Main.get_cuentas_cobrar(params)
    end

    def sustituirMonto(detalle, columnas_antiguedad = nil)
      Reportes::Main.sustituirMonto(detalle, columnas_antiguedad)
    end

    def antiguedad_bucket_definitions
      Reportes::Main.antiguedad_bucket_definitions
    end

    def antiguedad_bucket_keys
      Reportes::Main.antiguedad_bucket_keys
    end

    def parse_antiguedad_columns(params)
      Reportes::Main.parse_antiguedad_columns(params)
    end

    def normalize_antiguedad_bucket(value)
      Reportes::Main.normalize_antiguedad_bucket(value)
    end

    def antiguedad_bucket_selects(columnas_antiguedad, tipo)
      Reportes::Main.antiguedad_bucket_selects(columnas_antiguedad, tipo)
    end

    def build_antiguedad_filter_where(columnas_antiguedad)
      Reportes::Main.build_antiguedad_filter_where(columnas_antiguedad)
    end

    def calcularCantidades(articulos)
      Reportes::Main.calcularCantidades(articulos)
    end

    def get_inventario(params)
      Reportes::Main.get_inventario(params)
    end

    def get_notas(params)
      Reportes::Main.get_notas(params)
    end

    def get_recibos(params)
      Reportes::Main.get_recibos(params)
    end

    def sum_by_day_recibos(records)
      Reportes::Main.sum_by_day_recibos(records)
    end

    def get_suplidores_por_producto(params)
      Reportes::Main.get_suplidores_por_producto(params)
    end

    def get_movimientos_vehiculo(params)
      Reportes::Main.get_movimientos_vehiculo(params)
    end

    def get_cuentas_con_pagos(params)
      Reportes::Main.get_cuentas_con_pagos(params)
    end

    def get_ventas_por_producto(params)
      Reportes::Main.get_ventas_por_producto(params)
    end

    def calcular_cantidad_proporcional(detalle)
      Reportes::Main.calcular_cantidad_proporcional(detalle)
    end

    def get_ventas(params)
      Reportes::Main.get_ventas(params)
    end

    def sum_by_day_ventas(records)
      Reportes::Main.sum_by_day_ventas(records)
    end

    def get_balance_cliente_historico(params)
      Reportes::Main.get_balance_cliente_historico(params)
    end
  end
end
