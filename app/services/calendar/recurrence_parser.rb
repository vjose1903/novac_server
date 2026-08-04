module Calendar
  class RecurrenceParser
    TYPE_BY_FREQ = {
      'DAILY' => 'daily',
      'WEEKLY' => 'weekly',
      'MONTHLY' => 'monthly',
      'YEARLY' => 'yearly'
    }.freeze

    def initialize(rule)
      @rule = rule.to_s
    end

    def parse
      return { recurrence_type: 'none' } if @rule.blank?

      values = @rule.split(';').each_with_object({}) do |part, hash|
        key, value = part.split('=', 2)
        hash[key] = value
      end

      {
        recurrence_type: TYPE_BY_FREQ[values['FREQ']] || 'custom',
        recurrence_interval: values['INTERVAL'].to_i.positive? ? values['INTERVAL'].to_i : 1,
        recurrence_days: values['BYDAY'].to_s.split(',').reject(&:blank?),
        recurrence_count: values['COUNT']&.to_i,
        recurrence_until: parse_until(values['UNTIL'])
      }
    end

    private

    def parse_until(value)
      return nil if value.blank?

      Date.strptime(value[0, 8], '%Y%m%d')
    rescue ArgumentError
      nil
    end
  end
end
