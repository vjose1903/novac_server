class AddIsWorkingDayToCalendar < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_events, :is_working_day, :boolean, default: true, null: false
    add_column :global_holidays, :is_working_day, :boolean, default: false, null: false

    add_index :calendar_events, :is_working_day
    add_index :global_holidays, :is_working_day
  end
end
