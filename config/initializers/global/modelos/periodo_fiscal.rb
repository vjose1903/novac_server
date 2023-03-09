module Mes
  # Numbers

  ENERO           = 1
  FEBRERO         = 2
  MARZO           = 3
  ABRIL           = 4
  MAYO            = 5
  JUNIO           = 6
  JULIO           = 7
  AGOSTO          = 8
  SEPTIEMBRE      = 9
  OCTUBRE         = 10
  NOVIEMBRE       = 11
  DICIEMBRE       = 12


  # Labels
  LABELS = {
    :_1_          => 'enero',
    :_2_          => 'febrero',
    :_3_          => 'marzo',
    :_4_          => 'abril',
    :_5_          => 'mayo',
    :_6_          => 'junio',
    :_7_          => 'julio',
    :_8_          => 'agosto',
    :_9_          => 'septiembre',
    :_10_         => 'octubre',
    :_11_         => 'noviembre',
    :_12_         => 'diciembre'
  }

	def self.labels
		return LABELS
	end

  module Number

    def self.enero
      return ENERO
    end

    def self.febrero
      return FEBRERO
    end

    def self.marzo
      return MARZO
    end

    def self.abril
      return ABRIL
    end

    def self.mayo
      return MAYO
    end

    def self.junio
      return JUNIO
    end

    def self.julio
      return JULIO
    end

    def self.agosto
      return AGOSTO
    end

    def self.septiembre
      return SEPTIEMBRE
    end

    def self.octubre
      return OCTUBRE
    end

    def self.noviembre
      return NOVIEMBRE
    end

    def self.diciembre
      return DICIEMBRE
    end
  end

  module Label
    def self.byNumber(number)
      return LABELS[:"_#{number}_"]
    end
  end

end