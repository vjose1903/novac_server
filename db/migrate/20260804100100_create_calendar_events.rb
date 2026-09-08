class CreateCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :calendar_events, id: :uuid do |t|
      t.references :calendar_event_type, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :location
      t.string :color
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.boolean :all_day, default: false, null: false
      t.string :timezone, default: 'America/Santo_Domingo', null: false
      t.string :recurrence_type, default: 'none', null: false
      t.text :recurrence_rule
      t.integer :recurrence_interval, default: 1, null: false
      t.string :recurrence_days, array: true, default: []
      t.date :recurrence_until
      t.integer :recurrence_count
      t.string :google_uid
      t.string :ical_uid
      t.string :source, default: 'manual', null: false
      t.boolean :is_global, default: false, null: false
      t.boolean :is_holiday, default: false, null: false
      t.string :holiday_key
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :calendar_events, :starts_at
    add_index :calendar_events, :ends_at
    add_index :calendar_events, :start_date
    add_index :calendar_events, :end_date
    add_index :calendar_events, [:start_date, :end_date]
    add_index :calendar_events, [:is_global, :start_date, :end_date]
    add_index :calendar_events, :is_holiday
    add_index :calendar_events, :holiday_key
    add_index :calendar_events, :deleted_at
    add_index :calendar_events, :source
    add_index :calendar_events, :ical_uid, unique: true, where: 'ical_uid IS NOT NULL'
    add_index :calendar_events, :google_uid, where: 'google_uid IS NOT NULL'
    add_index :calendar_events, :holiday_key, unique: true, where: 'is_global = true AND is_holiday = true AND deleted_at IS NULL', name: 'idx_calendar_events_unique_global_holiday'
  end
end
