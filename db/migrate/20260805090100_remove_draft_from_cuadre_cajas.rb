class RemoveDraftFromCuadreCajas < ActiveRecord::Migration[7.0]
  def up
    change_column_default :cuadre_cajas, :status, from: 'draft', to: 'submitted'
    cuadre_caja = Class.new(ActiveRecord::Base) do
      self.table_name = 'cuadre_cajas'
    end

    cuadre_caja.where(status: 'draft').update_all(status: 'submitted')
  end

  def down
    change_column_default :cuadre_cajas, :status, from: 'submitted', to: 'draft'
  end
end
