class RemoveReviewedFromCuadreCajas < ActiveRecord::Migration[7.0]
  def change
    remove_reference :cuadre_cajas, :reviewed_by, foreign_key: { to_table: :users }
    remove_column :cuadre_cajas, :reviewed_at, :datetime
  end
end
