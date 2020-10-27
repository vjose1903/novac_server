class CreateCuadreCajas < ActiveRecord::Migration[5.2]
  def change
    create_table :cuadre_cajas do |t|
      t.references :user, foreign_key: true
      t.float :total_general
      t.float :total_venta_credito
      t.float :total_venta_contado
      t.float :total_recibo_ingreso
      t.float :total_anterior
      t.integer :numero_reporte

      t.timestamps
    end
  end
end
