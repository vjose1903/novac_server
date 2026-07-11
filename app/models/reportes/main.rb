module Reportes
  module Main
    extend self

    include Reportes::Shared::CommonHelpers
    include Reportes::Clientes::CuentasCobrar
    include Reportes::Clientes::BalanceHistorico
    include Reportes::Inventario::Inventario
    include Reportes::Notas::Notas
    include Reportes::Recibos::Recibos
    include Reportes::Suplidores::Productos
    include Reportes::Facturas::MovimientosVehiculo
    include Reportes::Facturas::CuentasConPagos
    include Reportes::Facturas::VentasPorProducto
    include Reportes::Facturas::Ventas
  end
end
