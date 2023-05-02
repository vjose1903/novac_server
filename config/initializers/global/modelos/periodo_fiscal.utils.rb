module Mes
  # Numbers

  NUMBERS = {
    :enero           => 1,
    :febrero         => 2,
    :marzo           => 3,
    :abril           => 4,
    :mayo            => 5,
    :junio           => 6,
    :julio           => 7,
    :agosto          => 8,
    :septiembre      => 9,
    :octubre         => 10,
    :noviembre       => 11,
    :diciembre       => 12,
	}.with_indifferent_access


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
  }.with_indifferent_access

  def self.numbers
    return NUMBERS
  end

  def self.labels
    return LABELS
  end

  module Number

    def self.enero
      return NUMBERS[:enero]
    end

    def self.febrero
      return NUMBERS[:febrero]
    end

    def self.marzo
      return NUMBERS[:marzo]
    end

    def self.abril
      return NUMBERS[:abril]
    end

    def self.mayo
      return NUMBERS[:mayo]
    end

    def self.junio
      return NUMBERS[:junio]
    end

    def self.julio
      return NUMBERS[:julio]
    end

    def self.agosto
      return NUMBERS[:agosto]
    end

    def self.septiembre
      return NUMBERS[:septiembre]
    end

    def self.octubre
      return NUMBERS[:octubre]
    end

    def self.noviembre
      return NUMBERS[:noviembre]
    end

    def self.diciembre
      return NUMBERS[:diciembre]
    end

    def self.byLabel(label)
      return NUMBERS[:"#{label}"]
    end

  end

  module Label
    def self.byNumber(number)
      return LABELS[:"_#{number}_"]
    end
  end

end