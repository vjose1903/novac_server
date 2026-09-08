class CalendarEventLink < ApplicationRecord
  belongs_to :calendar_event
  belongs_to :linkable, polymorphic: true, optional: true

  validates :linkable_type, presence: { message: 'Tipo de relación no puede estar vacio.' }
  validates :linkable_id, presence: { message: 'ID de relación no puede estar vacio.' }
  validates :linkable_id, uniqueness: { scope: [:calendar_event_id, :linkable_type], message: 'La relación ya existe para este evento.' }

  before_validation :normalize_linkable_type

  def self.models_includes
    [:calendar_event]
  end

  private

  def normalize_linkable_type
    self.linkable_type = linkable_type.to_s.strip if linkable_type.present?
  end
end
