class CreateGlobalHolidays < ActiveRecord::Migration[7.0]
  def change
    create_table :global_holidays, id: :uuid do |t|
      t.string :country_code, default: 'DO', null: false
      t.string :holiday_key, null: false
      t.string :name, null: false
      t.date :date, null: false
      t.date :observed_date
      t.integer :year, null: false
      t.string :source, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :global_holidays, :country_code
    add_index :global_holidays, :year
    add_index :global_holidays, :date
    add_index :global_holidays, :observed_date
    add_index :global_holidays, [:country_code, :holiday_key], unique: true
    add_index :global_holidays, [:country_code, :date, :name], unique: true
  end
end
