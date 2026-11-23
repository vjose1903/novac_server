class CreateDetallesPeriodosFiscales < ActiveRecord::Migration[7.0]
  def change
    create_table :detalles_periodos_fiscales do |t|
      t.references :periodo_fiscal, null: false, foreign_key: true
      t.boolean    :enero
      t.boolean    :febrero
      t.boolean    :marzo
      t.boolean    :abril
      t.boolean    :mayo
      t.boolean    :junio
      t.boolean    :julio
      t.boolean    :agosto
      t.boolean    :septiembre
      t.boolean    :octubre
      t.boolean    :noviembre
      t.boolean    :diciembre

      t.timestamps
    end
  end
end
