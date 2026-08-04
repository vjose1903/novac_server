class CreateCalendarEventLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_event_links, id: :uuid do |t|
      t.uuid :calendar_event_id, null: false
      t.string :linkable_type, null: false
      t.bigint :linkable_id, null: false
      t.string :label
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_foreign_key :calendar_event_links, :calendar_events
    add_index :calendar_event_links, :calendar_event_id
    add_index :calendar_event_links, [:linkable_type, :linkable_id]
    add_index :calendar_event_links, [:calendar_event_id, :linkable_type, :linkable_id], unique: true, name: 'idx_calendar_event_links_unique_link'
  end
end
