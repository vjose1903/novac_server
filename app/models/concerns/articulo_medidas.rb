module ArticuloMedidas
  extend ActiveSupport::Concern

  SACOS_CALCULADOS = [100, 50, 25]

  class_methods do
    def contenidos_calculados(articulo, sacos = true)
      contenidos = sacos_calculados(articulo, sacos)
      contenido = articulo.contenido_articulos
      medida = medida_articulo(articulo)

      contenidos[medida] = contenido.empty? ? 1 : contenido.first["cantidad"]
      contenidos[contenido.first["medida"]] = 1 if contenido.any?

      return contenidos if contenido.length != 2

      cant_principal = contenido.reduce(1) { |total, conte| total * conte["cantidad"] }
      cant_padre = contenido.find { |conte| conte["referencia"] }&.dig("cantidad") || 1

      contenidos[medida] = cant_principal
      contenidos[contenido[0]["medida"]] = cant_padre
      contenidos[contenido[1]["medida"]] = 1
      contenidos
    end

    def cantidades_calculadas(articulo)
      contenido = articulo.contenido_articulos
      existencia = articulo["existencia"].nil? ? 0 : articulo["existencia"]
      medida = medida_articulo(articulo)
      cantidades = {}.with_indifferent_access

      cantidades[medida] = contenido.empty? ? existencia : (existencia / contenido.first["cantidad"])
      cantidades[contenido.first["medida"]] = existencia if contenido.any?

      return cantidades if contenido.length != 2

      max_cantidad = contenido.reduce(1) { |total, conte| total * conte["cantidad"] }
      cantidad_padre = contenido.find { |conte| conte["condicion"] == "hijo" }&.dig("cantidad") || 1

      cantidades[medida] = existencia / max_cantidad
      cantidades[contenido[0]["medida"]] = existencia / cantidad_padre
      cantidades[contenido[1]["medida"]] = existencia
      cantidades
    end

    def costos_calculados(articulo)
      costos = {
        "#{articulo.medida}" => {
          "costo" => articulo.costo_principal,
          "precio" => articulo.precio_principal
        }.with_indifferent_access
      }.with_indifferent_access

      articulo.contenido_articulos.each do |contenido|
        costos[contenido.medida] = {
          "costo" => contenido.costo,
          "precio" => contenido.precio
        }
      end

      return costos unless articulo.calcular_saco && costos["Quintal"].present?

      SACOS_CALCULADOS.each do |peso|
        costos["Saco_#{peso}"] = {
          "costo" => (peso / 100.to_f) * costos["Quintal"]["costo"],
          "precio" => (peso / 100.to_f) * costos["Quintal"]["precio"]
        }.with_indifferent_access
      end

      costos
    end

    def medida_articulo(articulo)
      medida = articulo["medida"]
      return articulo.tipo_articulo.tipo.titleize if medida == "N/A" || medida.nil?

      medida
    end

    def sacos_calculados(articulo, sacos)
      return {} unless sacos && articulo["vendido_en"] == "Saco" && articulo["calcular_saco"]

      SACOS_CALCULADOS.each_with_object({}) { |peso, contenidos| contenidos["Saco_#{peso}"] = peso }
    end

    private(
      :medida_articulo,
      :sacos_calculados
    )
  end
end
