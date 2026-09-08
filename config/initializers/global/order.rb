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

  def self.parse_safe(order, allowed_columns, default_order)
    orders = parse_items(order).map do |column, direction|
      column_sql = allowed_columns[column.to_s]
      next if column_sql.nil?

      direction = direction.to_s.downcase
      direction = "asc" unless %w[asc desc].include?(direction)
      "#{column_sql} #{direction}"
    end.compact

    orders.empty? ? default_order : orders.join(", ")
  end

  def self.parse_items(order)
    return [] if order.blank?

    order = order.to_unsafe_h if order.respond_to?(:to_unsafe_h)

    return order.map { |column, direction| [column, direction] } if order.is_a?(Hash)
    return order.flat_map { |item| parse_items(item) } if order.is_a?(Array)

    order.to_s.split(",").map { |item| item.strip.split(":", 2) }
  end
end
