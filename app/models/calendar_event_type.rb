class CalendarEventType < ApplicationRecord
  HEX_COLOR_FORMAT = /\A#[0-9A-Fa-f]{6}\z/

  has_many :calendar_events

  validates :name, presence: { message: 'Nombre del tipo de evento no puede estar vacio.' }
  validates :slug, presence: { message: 'Slug del tipo de evento no puede estar vacio.' }, uniqueness: { case_sensitive: false, message: 'Slug del tipo de evento ya existe.' }
  validates :color, presence: { message: 'Color del tipo de evento no puede estar vacio.' }, format: { with: HEX_COLOR_FORMAT, message: 'Color del tipo de evento debe tener formato HEX.' }

  before_validation :normalize_slug

  scope :active, -> { where(active: true) }
  scope :system, -> { where(is_system: true) }
  scope :ordered, -> { order('sort_order ASC, name ASC') }

  DEFAULT_TYPES = [
    { name: 'Llamada', slug: 'call', color: '#2563eb', is_system: true, active: true, sort_order: 10 },
    { name: 'Recordatorio', slug: 'reminder', color: '#f59e0b', is_system: true, active: true, sort_order: 20 },
    { name: 'Reunión', slug: 'meeting', color: '#7c3aed', is_system: true, active: true, sort_order: 40 },
    { name: 'Seguimiento', slug: 'follow_up', color: '#0891b2', is_system: true, active: true, sort_order: 50 },
    { name: 'Día festivo', slug: 'holiday', color: '#dc2626', is_system: true, active: true, sort_order: 60 }
  ].freeze

  def self.models_includes
    []
  end

  def self.seed_defaults
    DEFAULT_TYPES.each do |type_data|
      event_type = CalendarEventType.where(slug: type_data[:slug]).first_or_initialize
      event_type.assign_attributes(type_data)
      event_type.save!
    end
  end

  def self.holiday_type
    active.find_by(slug: 'holiday') || find_by(slug: 'holiday')
  end

  def self.get_event_types(params, paginate_options)
    res = Response.new(paginate_options)
    event_types = CalendarEventType.ordered

    if event_types.exists?
      res.set_data(event_types, { all: true })
    else
      res.set_data([])
      res.add_msg('No existen tipos de evento registrados.')
      res.set_status(HTTP_STATUS_CODE[:not_found])
    end

    res
  end

  def self.create_update_event_type(params)
    res = Response.new

    CalendarEventType.transaction do
      event_type = CalendarEventType.where(id: params[:id]).first_or_initialize

      event_type.name = params[:name] if params.obj_has?(:name)
      event_type.slug = params[:slug] if params.obj_has?(:slug)
      event_type.color = params[:color] if params.obj_has?(:color)
      event_type.is_system = params[:is_system] if params.obj_has?(:is_system)
      event_type.active = params[:active] if params.obj_has?(:active)
      event_type.sort_order = params[:sort_order] if params.obj_has?(:sort_order)

      if event_type.save
        action = params[:id] ? 'actualizado' : 'creado'
        res.set_data(event_type, { all: true })
        res.add_msg("Tipo de evento #{action} correctamente.")
      else
        res.add_msgs(event_type.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless res.status_valid
    end

    res
  end

  def self.deactivate_event_type(id)
    res = Response.new
    event_type = CalendarEventType.find_by_id(id)

    unless event_type
      res.add_msg('No se encuentra el tipo de evento.')
      res.set_status(HTTP_STATUS_CODE[:not_found])
      return res
    end

    event_type.active = false

    if event_type.save
      res.set_data(event_type, { all: true })
      res.add_msg('Tipo de evento desactivado correctamente.')
    else
      res.add_msgs(event_type.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    res
  end

  private

  def normalize_slug
    self.slug = slug.to_s.strip.downcase.parameterize(separator: '_') if slug.present?
  end
end
