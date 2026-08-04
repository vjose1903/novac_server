class GlobalHoliday < ApplicationRecord
  validates :country_code, presence: { message: 'Código de país no puede estar vacio.' }
  validates :holiday_key, presence: { message: 'Key del día festivo no puede estar vacio.' }, uniqueness: { scope: :country_code, message: 'Día festivo ya existe.' }
  validates :name, presence: { message: 'Nombre del día festivo no puede estar vacio.' }
  validates :date, presence: { message: 'Fecha del día festivo no puede estar vacia.' }
  validates :year, presence: { message: 'Año del día festivo no puede estar vacio.' }
  validates :source, presence: { message: 'Origen del día festivo no puede estar vacio.' }

  before_validation :set_defaults

  def effective_date
    observed_date || date
  end

  private

  def set_defaults
    self.country_code = 'DO' if country_code.blank?
    self.year = effective_date&.year if year.blank? && effective_date.present?
    self.is_working_day = false if is_working_day.nil?
  end
end
