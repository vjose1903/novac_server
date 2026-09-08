class CalendarEvent < ApplicationRecord
  TIMEZONE_DEFAULT = 'America/Santo_Domingo'
  RECURRENCE_TYPES = %w[none daily weekly monthly yearly custom].freeze
  SOURCES = %w[manual holiday google ical import].freeze
  HEX_COLOR_FORMAT = /\A#[0-9A-Fa-f]{6}\z/

  belongs_to :calendar_event_type
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :calendar_event_links, dependent: :destroy

  validates :title, presence: { message: 'Título del evento no puede estar vacio.' }
  validates :starts_at, presence: { message: 'Fecha inicial del evento no puede estar vacia.' }
  validates :ends_at, presence: { message: 'Fecha final del evento no puede estar vacia.' }
  validates :start_date, presence: { message: 'Fecha inicial del evento no puede estar vacia.' }
  validates :end_date, presence: { message: 'Fecha final del evento no puede estar vacia.' }
  validates :timezone, presence: { message: 'Zona horaria del evento no puede estar vacia.' }
  validates :recurrence_type, inclusion: { in: RECURRENCE_TYPES, message: 'Tipo de recurrencia inválido.' }
  validates :source, inclusion: { in: SOURCES, message: 'Origen del evento inválido.' }
  validates :color, format: { with: HEX_COLOR_FORMAT, message: 'Color del evento debe tener formato HEX.' }, allow_blank: true
  validates :recurrence_interval, numericality: { greater_than_or_equal_to: 1, message: 'Intervalo de recurrencia inválido.' }

  validate :validate_date_ranges
  validate :validate_holiday_fields

  before_validation :set_defaults
  before_validation :assign_dates_from_datetimes
  before_validation :assign_ical_uid

  scope :active, -> { where(deleted_at: nil) }
  scope :global, -> { where(is_global: true) }
  scope :holidays, -> { where(is_holiday: true) }
  scope :intersecting_range, ->(range_start, range_end) { where('calendar_events.start_date <= ? AND calendar_events.end_date >= ?', range_end, range_start) }

  def self.next_working_day_after(date)
    next_date = date.to_date + 1.day

    loop do
      return next_date unless non_working_day?(next_date)

      next_date += 1.day
    end
  end

  def self.non_working_day?(date)
    date = date.to_date
    return true if date.sunday?

    events = CalendarEvent.active.intersecting_range(date, date)
    return false unless events.exists?

    # Un evento/rango no laborable bloquea el dia completo. Si todos los eventos
    # del dia estan marcados laborables, el dia queda disponible.
    events.where(is_working_day: false).exists?
  end

  def self.models_includes
    [
      :calendar_event_type,
      :created_by,
      :updated_by,
      :calendar_event_links
    ]
  end

  def self.get_events_by_range(params, parametros_opcionales)
    res = Response.new
    parsed_range = parse_range(params)
    return parsed_range unless parsed_range.status_valid

    range_start = parsed_range.get_data[:range_start]
    range_end = parsed_range.get_data[:range_end]

    events = CalendarEvent
      .active
      .intersecting_range(range_start, range_end)
      .includes(models_includes)
      .order('calendar_events.start_date ASC, calendar_events.starts_at ASC')

    data = Calendar::EventSerializer.new(events, include_links: parametros_opcionales[:links]).as_json
    res.set_data(data)
    res
  end

  def self.create_event(params)
    res = Response.new

    CalendarEvent.transaction do
      event = build_event(CalendarEvent.new, params, :create)

      if event.errors.empty? && event.save
        res_links = sync_links(event, params[:links], replace: true)

        if res_links.status_valid
          res_holiday = sync_global_holiday_from_event(event.reload, nil)

          unless res_holiday.status_valid
            res.add_msgs(res_holiday.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
            raise ActiveRecord::Rollback
          end

          res.set_data(event.reload, { all: true, google_calendar_url: true, links: true }, models_includes)
          res.add_msg('Evento creado correctamente.')
        else
          res.add_msgs(res_links.get_msgs.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
      else
        res.add_msgs(event.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless res.status_valid
    end

    res
  end

  def self.update_event(params)
    res = Response.new

    CalendarEvent.transaction do
      event = CalendarEvent.active.find_by_id(params[:id])
      original_holiday_key = event&.holiday_key

      if event.nil?
        res.add_msg('No se encuentra el evento a editar.')
        res.set_status(HTTP_STATUS_CODE[:not_found])
      else
        event = build_event(event, params, :update)

        if event.errors.empty? && event.save
          res_holiday = sync_global_holiday_from_event(event, original_holiday_key)
          res_links = res_holiday.status_valid && params.key?(:links) ? sync_links(event, params[:links], replace: true) : Response.new

          if res_holiday.status_valid && res_links.status_valid
            res.set_data(event.reload, { all: true, google_calendar_url: true, links: true }, models_includes)
            res.add_msg('Evento actualizado correctamente.')
          else
            res.add_msgs(res_holiday.get_msgs.to_a)
            res.add_msgs(res_links.get_msgs.to_a)
            res.set_status(HTTP_STATUS_CODE[:conflict])
          end
        else
          res.add_msgs(event.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
      end

      raise ActiveRecord::Rollback unless res.status_valid
    end

    res
  end

  def self.delete_event(params)
    res = Response.new
    event = CalendarEvent.active.find_by_id(params[:id])

    unless event
      res.add_msg('No se encuentra el evento a eliminar.')
      res.set_status(HTTP_STATUS_CODE[:not_found])
      return res
    end

    if event.is_holiday
      res.add_msg('Los días festivos no se pueden eliminar desde este endpoint.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
      return res
    end

    event.deleted_at = Time.current
    event.updated_by_id = get_current_user&.id

    if event.save
      res.set_data(event, { all: true })
      res.add_msg('Evento eliminado correctamente.')
    else
      res.add_msgs(event.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    res
  end

  def display_color
    color.presence || calendar_event_type.color
  end

  def google_calendar_url
    Calendar::GoogleCalendarUrlBuilder.new(self).url
  end

  private_class_method def self.parse_range(params)
    res = Response.new

    begin
      range_start = Date.parse(params[:start].to_s)
      range_end = Date.parse(params[:end].to_s)
    rescue ArgumentError
      res.add_msg('Rango de fechas inválido.')
      res.set_status(HTTP_STATUS_CODE[:bad_request])
      return res
    end

    if range_end < range_start
      res.add_msg('Fecha final del rango no puede ser menor que la fecha inicial.')
      res.set_status(HTTP_STATUS_CODE[:bad_request])
      return res
    end

    res.set_data({ range_start: range_start, range_end: range_end })
    res
  end

  private_class_method def self.build_event(event, params, action)
    event.calendar_event_type_id = params[:calendar_event_type_id] if params.obj_has?(:calendar_event_type_id)
    event.title = params[:title] if params.obj_has?(:title)
    event.description = params[:description] if params.obj_has?(:description)
    event.location = params[:location] if params.obj_has?(:location)
    event.color = params[:color] if params.obj_has?(:color)
    event.all_day = params[:all_day] if params.obj_has?(:all_day)
    event.timezone = params[:timezone] if params.obj_has?(:timezone)
    event.recurrence_type = params[:recurrence_type] if params.obj_has?(:recurrence_type)
    event.recurrence_interval = params[:recurrence_interval] if params.obj_has?(:recurrence_interval)
    event.recurrence_days = params[:recurrence_days] if params.obj_has?(:recurrence_days)
    event.recurrence_until = params[:recurrence_until] if params.obj_has?(:recurrence_until)
    event.recurrence_count = params[:recurrence_count] if params.obj_has?(:recurrence_count)
    event.is_holiday = params[:is_holiday] if params.obj_has?(:is_holiday)
    event.is_global = params[:is_global] if params.obj_has?(:is_global)

    if action == :create || recurrence_params_present?(params)
      event.recurrence_rule = params.obj_has?(:recurrence_rule) ? params[:recurrence_rule] : Calendar::RecurrenceBuilder.new(params).rule
    end

    event.google_uid = params[:google_uid] if params.obj_has?(:google_uid)
    event.holiday_key = params[:holiday_key] if event.is_holiday && params.obj_has?(:holiday_key)
    event.is_working_day = params[:is_working_day] if params.obj_has?(:is_working_day)
    event.is_global = true if event.is_holiday
    event.source = 'holiday' if event.is_holiday
    event.is_global = false unless event.is_global
    event.is_holiday = false unless event.is_holiday
    event.created_by_id = get_current_user&.id if action == :create
    event.updated_by_id = get_current_user&.id

    assign_event_dates(event, params)
    event.holiday_key = build_holiday_key(event.start_date, event.title) if event.is_holiday && event.holiday_key.blank? && event.start_date.present? && event.title.present?
    event.valid?
    event
  end

  private_class_method def self.build_holiday_key(date, title)
    "DO-#{date.strftime('%Y-%m-%d')}-#{title.to_s.parameterize}"
  end

  private_class_method def self.sync_global_holiday_from_event(event, original_holiday_key)
    res = Response.new
    return res unless event.is_holiday

    lookup_holiday_key = original_holiday_key.presence || event.holiday_key
    holiday = GlobalHoliday.where(country_code: 'DO', holiday_key: lookup_holiday_key).first_or_initialize
    event.holiday_key = lookup_holiday_key if event.holiday_key.blank?

    holiday.assign_attributes(
      holiday_key: event.holiday_key,
      name: event.title,
      date: event.start_date,
      observed_date: nil,
      year: event.start_date.year,
      source: 'manual',
      is_working_day: event.is_working_day,
      metadata: holiday.metadata || {}
    )

    return res if holiday.save

    res.add_msgs(holiday.errors.to_a)
    res.set_status(HTTP_STATUS_CODE[:conflict])
    res
  end

  private_class_method def self.recurrence_params_present?(params)
    [:recurrence_type, :recurrence_rule, :recurrence_interval, :recurrence_days, :recurrence_until, :recurrence_count].any? { |key| params.obj_has?(key) }
  end

  private_class_method def self.assign_event_dates(event, params)
    return unless params.obj_has?(:start_date) || params.obj_has?(:end_date) || params.obj_has?(:start_time) || params.obj_has?(:end_time) || params.obj_has?(:all_day)

    timezone = ActiveSupport::TimeZone[event.timezone.presence || TIMEZONE_DEFAULT] || ActiveSupport::TimeZone[TIMEZONE_DEFAULT]
    start_date = params.obj_has?(:start_date) ? Date.parse(params[:start_date].to_s) : event.start_date
    end_date = params.obj_has?(:end_date) ? Date.parse(params[:end_date].to_s) : event.end_date || start_date

    if event.all_day
      event.start_date = start_date
      event.end_date = end_date
      event.starts_at = timezone.local(start_date.year, start_date.month, start_date.day).beginning_of_day
      event.ends_at = timezone.local(end_date.year, end_date.month, end_date.day).end_of_day
      return
    end

    start_time = params.obj_has?(:start_time) ? params[:start_time].to_s : event.starts_at&.strftime('%H:%M')
    end_time = params.obj_has?(:end_time) ? params[:end_time].to_s : event.ends_at&.strftime('%H:%M')

    validate_time_increment(event, start_time, 'Hora inicial')
    validate_time_increment(event, end_time, 'Hora final')
    return unless event.errors.empty?

    event.start_date = start_date
    event.end_date = end_date
    event.starts_at = parse_datetime(timezone, start_date, start_time)
    event.ends_at = parse_datetime(timezone, end_date, end_time)
  rescue ArgumentError
    event.errors.add(:base, 'Fecha u hora del evento inválida.')
  end

  private_class_method def self.parse_datetime(timezone, date, time_value)
    hour, minute = time_value.to_s.split(':').map(&:to_i)
    timezone.local(date.year, date.month, date.day, hour, minute)
  end

  private_class_method def self.validate_time_increment(event, time_value, label)
    unless time_value.to_s.match?(/\A\d{2}:\d{2}\z/)
      event.errors.add(:base, "#{label} inválida.")
      return
    end

    minute = time_value.to_s.split(':').last.to_i
    event.errors.add(:base, "#{label} debe estar en intervalos de 5 minutos.") unless (minute % 5).zero?
  end

  private_class_method def self.sync_links(event, links, replace:)
    res = Response.new
    links = [] if links.nil?

    unless links.respond_to?(:each)
      res.add_msg('Formato de relaciones inválido.')
      res.set_status(HTTP_STATUS_CODE[:bad_request])
      return res
    end

    event.calendar_event_links.destroy_all if replace

    links.each do |link_params|
      link = event.calendar_event_links.build
      link.linkable_type = link_params[:linkable_type] || link_params['linkable_type']
      link.linkable_id = link_params[:linkable_id] || link_params['linkable_id']
      link.label = link_params[:label] || link_params['label']
      link.metadata = link_params[:metadata] || link_params['metadata'] || {}

      next if link.save

      res.add_msgs(link.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
      break
    end

    res
  end

  def set_defaults
    self.timezone = TIMEZONE_DEFAULT if timezone.blank?
    self.recurrence_type = 'none' if recurrence_type.blank?
    self.recurrence_interval = 1 if recurrence_interval.blank?
    self.source = 'manual' if source.blank?
    self.recurrence_days = [] if recurrence_days.nil?
    self.is_working_day = false if is_holiday && is_working_day.nil?
    self.is_working_day = true if is_working_day.nil?
  end

  def assign_dates_from_datetimes
    self.start_date = starts_at.to_date if start_date.blank? && starts_at.present?
    self.end_date = ends_at.to_date if end_date.blank? && ends_at.present?
  end

  def assign_ical_uid
    self.ical_uid = "#{SecureRandom.uuid}@novac-calendar" if ical_uid.blank?
  end

  def validate_date_ranges
    errors.add(:base, 'Fecha final del evento no puede ser menor que la fecha inicial.') if starts_at.present? && ends_at.present? && ends_at < starts_at
    errors.add(:base, 'Fecha final del evento no puede ser menor que la fecha inicial.') if start_date.present? && end_date.present? && end_date < start_date
  end

  def validate_holiday_fields
    return unless is_holiday

    errors.add(:base, 'Los días festivos deben ser eventos globales.') unless is_global
    errors.add(:base, 'Los días festivos deben tener holiday_key.') if holiday_key.blank?
  end
end
