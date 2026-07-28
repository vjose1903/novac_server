class CuadreCajaEvento < ApplicationRecord
  self.table_name = 'cuadre_caja_eventos'

  belongs_to :cuadre_caja
  belongs_to :user, optional: true
end
