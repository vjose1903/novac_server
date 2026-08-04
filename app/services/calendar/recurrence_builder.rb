module Calendar
  class RecurrenceBuilder
    FREQ_BY_TYPE = {
      'daily' => 'DAILY',
      'weekly' => 'WEEKLY',
      'monthly' => 'MONTHLY',
      'yearly' => 'YEARLY'
    }.freeze

    def initialize(params)
      @params = params
    end

    def rule
      recurrence_type = @params[:recurrence_type].to_s
      return nil if recurrence_type.blank? || recurrence_type == 'none'
      return @params[:recurrence_rule] if recurrence_type == 'custom' && @params[:recurrence_rule].present?

      freq = FREQ_BY_TYPE[recurrence_type]
      return nil unless freq

      parts = ["FREQ=#{freq}", "INTERVAL=#{interval}"]
      parts << "BYDAY=#{days.join(',')}" if recurrence_type == 'weekly' && days.any?
      parts << "UNTIL=#{until_value}" if @params[:recurrence_until].present?
      parts << "COUNT=#{@params[:recurrence_count].to_i}" if @params[:recurrence_count].present?
      parts.join(';')
    end

    private

    def interval
      value = @params[:recurrence_interval].to_i
      value.positive? ? value : 1
    end

    def days
      raw_days = @params[:recurrence_days] || []
      raw_days.respond_to?(:map) ? raw_days.map { |day| day.to_s.upcase } : []
    end

    def until_value
      Date.parse(@params[:recurrence_until].to_s).strftime('%Y%m%dT235959Z')
    end
  end
end
