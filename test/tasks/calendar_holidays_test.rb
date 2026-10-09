require 'test_helper'
require 'minitest/mock'
require 'rake'

class CalendarHolidaysTaskTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers
  self.fixture_table_names = []

  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('calendar:holidays:ensure_next_three_years')
  end

  test 'completa años y eventos faltantes con fechas dinámicas y no modifica datos completos' do
    travel_to(Time.zone.local(2027, 1, 1)) do
      years = [2027, 2028, 2029]
      expected_holidays = holidays_for(years)
      sync_result = Calendar::HolidaySyncService.new(
        years: [years.first],
        provider: provider_for([expected_holidays.first])
      ).call
      assert sync_result.status_valid, sync_result.get_msgs.join(', ')

      run_task_with(expected_holidays)

      assert_equal years, GlobalHoliday.where(country_code: 'DO').order(:year).distinct.pluck(:year)
      assert_equal years.length, CalendarEvent.active.where(is_global: true, is_holiday: true).count

      timestamps = GlobalHoliday.order(:year).pluck(:updated_at)
      run_task_with(expected_holidays)
      assert_equal timestamps, GlobalHoliday.order(:year).pluck(:updated_at)
      assert_equal years.length, GlobalHoliday.where(country_code: 'DO').count
    end
  end

  test 'restaura el evento global si había sido eliminado' do
    years = [Date.current.year, Date.current.year + 1, Date.current.year + 2]
    expected_holidays = holidays_for(years)
    run_task_with(expected_holidays)

    event = CalendarEvent.find_by!(holiday_key: expected_holidays.first['holiday_key'])
    event.update!(deleted_at: Time.current)
    run_task_with(expected_holidays)

    assert_nil event.reload.deleted_at
    assert_equal 1, CalendarEvent.where(holiday_key: event.holiday_key, is_global: true, is_holiday: true, deleted_at: nil).count
  end

  private

  def run_task_with(holidays)
    task = Rake::Task['calendar:holidays:ensure_next_three_years']
    task.reenable
    provider_factory = ->(years:) { provider_for(holidays) }
    Calendar::HolidayPythonProvider.stub(:new, provider_factory) { task.invoke }
  end

  def provider_for(holidays)
    provider = Object.new
    provider.define_singleton_method(:call) { holidays }
    provider
  end

  def holidays_for(years)
    years.map do |year|
      date = Date.new(year, 1, 1)
      {
        'name' => "Feriado #{year}",
        'date' => date.iso8601,
        'observed_date' => nil,
        'holiday_key' => "DO-#{date.strftime('%Y-%m-%d')}-feriado-#{year}",
        'source' => 'test',
        'is_working_day' => false,
        'metadata' => {}
      }
    end
  end
end
