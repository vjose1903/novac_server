class CreateCierreCuentas < ActiveRecord::Migration[7.0]
  def change
    create_table :cierre_cuentas do |t|
      t.references :periodo_fiscal, null: false, foreign_key: true
      t.references :cuenta_contable, null: false, foreign_key: true
      t.float :enero,                   :default => 0
      t.float :enero_debito,            :default => 0
      t.float :enero_credito,           :default => 0
      t.float :febrero,                 :default => 0
      t.float :febrero_debito,          :default => 0
      t.float :febrero_credito,         :default => 0
      t.float :marzo,                   :default => 0
      t.float :marzo_debito,            :default => 0
      t.float :marzo_credito,           :default => 0
      t.float :abril,                   :default => 0
      t.float :abril_debito,            :default => 0
      t.float :abril_credito,           :default => 0
      t.float :mayo,                    :default => 0
      t.float :mayo_debito,             :default => 0
      t.float :mayo_credito,            :default => 0
      t.float :junio,                   :default => 0
      t.float :junio_debito,            :default => 0
      t.float :junio_credito,           :default => 0
      t.float :julio,                   :default => 0
      t.float :julio_debito,            :default => 0
      t.float :julio_credito,           :default => 0
      t.float :agosto,                  :default => 0
      t.float :agosto_debito,           :default => 0
      t.float :agosto_credito,          :default => 0
      t.float :septiembre,              :default => 0
      t.float :septiembre_debito,       :default => 0
      t.float :septiembre_credito,      :default => 0
      t.float :octubre,                 :default => 0
      t.float :octubre_debito,          :default => 0
      t.float :octubre_credito,         :default => 0
      t.float :noviembre,               :default => 0
      t.float :noviembre_debito,        :default => 0
      t.float :noviembre_credito,       :default => 0
      t.float :diciembre,               :default => 0
      t.float :diciembre_debito,        :default => 0
      t.float :diciembre_credito,       :default => 0
      t.float :total_anual,             :default => 0

      t.timestamps
    end
  end
end
