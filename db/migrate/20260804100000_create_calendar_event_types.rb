class CreateCalendarEventTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_event_types do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :color, null: false
      t.boolean :is_system, default: false, null: false
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false

      t.timestamps
    end

    add_index :calendar_event_types, :slug, unique: true
    add_index :calendar_event_types, :active
    add_index :calendar_event_types, :sort_order
  end
end
