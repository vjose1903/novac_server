class AddSourceKeyToCuadreCajaMovimientos < ActiveRecord::Migration[7.2]
  def change
    add_column :cuadre_caja_movimientos, :source_key, :string
    add_index :cuadre_caja_movimientos, [:cuadre_caja_id, :source_key], unique: true,
      where: 'source_key IS NOT NULL', name: 'idx_cuadre_movimientos_source_key'
  end
end
