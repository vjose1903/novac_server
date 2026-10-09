require 'test_helper'

class CalendarHolidaySyncServiceTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test 'sincronizar varias veces no duplica feriados ni eventos' do
    date = Date.current.beginning_of_year
    holiday = {
      'name' => 'Feriado de prueba',
      'date' => date.iso8601,
      'observed_date' => nil,
      'source' => 'test',
      'is_working_day' => false,
      'metadata' => {}
    }
    provider = Object.new
    provider.define_singleton_method(:call) { [holiday] }

    2.times do
      result = Calendar::HolidaySyncService.new(years: [date.year], provider: provider).call
      assert result.status_valid, result.get_msgs.join(', ')
    end

    key = "DO-#{date.strftime('%Y-%m-%d')}-feriado-de-prueba"
    assert_equal 1, GlobalHoliday.where(country_code: 'DO', holiday_key: key).count
    assert_equal 1, CalendarEvent.where(holiday_key: key, is_global: true, is_holiday: true, deleted_at: nil).count
  end
end
