require 'json'
require 'open3'

module Calendar
  class HolidayPythonProvider
    def initialize(years:)
      @years = Array(years).map(&:to_i).uniq.sort
    end

    def call
      stdout, stderr, status = Open3.capture3(
        'python3',
        Rails.root.join('scripts/holidays_rd.py').to_s,
        *@years.map(&:to_s)
      )

      raise "Error generando feriados RD: #{stderr}" unless status.success?

      JSON.parse(stdout)
    end
  end
end
