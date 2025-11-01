module ORDER_MANAGER
  def self.parse(order)
    return nil if order.nil?

    orders = order.split(",").map do |col|
      column, direction = col.strip.split(":")
      direction = %w[asc desc].include?(direction) ? direction : "asc"
      "#{column} #{direction}"
    end

    orders.compact.join(", ")

  end
end