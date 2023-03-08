class CreatePeriodosFiscales < ActiveRecord::Migration[7.0]
  def change
    create_table :periodos_fiscales do |t|
      t.date :fecha_inicio
      t.date :fecha_cierre
      t.boolean :estado

      t.timestamps
    end
  end
end
