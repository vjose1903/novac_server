class ArticulosController < ApplicationController
  before_action :set_articulo, only: [:show, :update, :destroy]

  # GET /articulos
  def index
    @articulos = []
    Articulo.all.each do |articulo|
      if articulo["estado"] == true
        @articulos.push(articulo)
      end
    end
    render json: @articulos
  end

  def getArticulosFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    articulos = Articulo.filtrarArticulo(arg)

    articulos_ = Articulo.parsearArticulosFiltro(articulos)

    res = []

    if paginado
      res = articulos_.to_a.my_paginate(page, per_page)
      res[:data].each do |arti|
        arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
      end
    else
      res = articulos_
      res.each do |arti|
        arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
      end
    end

    render json: res
  end

  def getArticuloByNameObyCodigo
    tipo_ = params[:tipo]
    nom_ = params[:nombre]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    articulos_ = []
    res = nil

    @articulos = Articulo.get_articulo_by_name_o_by_codigo(tipo_, nom_)

    if tipo_ == "nombre"
      @articulos.each do |art|
        articulos_.push(Articulo.parsearArticulos(art))
      end

      if articulos_.length === 0
        if paginado
          res = { data: { msg: "Articulo buscado no existe." }, status: :unprocessable_entity }
        else
          res = { data: { msg: "Articulo buscado no existe." }, status: :unprocessable_entity }
        end
      else
        if paginado
          article = articulos_.to_a.my_paginate(page, per_page)

          article[:data].each do |arti|
            arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
          end

          res = { data: article, status: 200 }
          # res = { data: articulos_.to_a.my_paginate(page, per_page), status: 200 }
        else
          articulos_.each do |arti|
            arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
          end
          res = { data: articulos_, status: 200 }
        end
      end
    else
      if @articulos[0].nil?
        res = { data: { msg: "No existe articulo con el codigo introducido." }, status: :unprocessable_entity }
      else
        article = Articulo.parsearArticulos(@articulos[0])
        article["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: article["id"] })
        res = { data: article, status: 200 }
      end
    end

    render json: res[:data], status: res[:status] # estructura para devolver info
  end

  # GET /articulos/1
  def show
    @articulo
    if @articulo["estado"] == false
      @articulo = { "nombre": "Este articulo esta desactivado." }
    end
    res = Articulo.parsearArticulos(@articulo)
    render json: res
  end

  # POST /articulos
  def create
    Articulo.transaction do
      @usuario_id = params["user_id"]

      @articulo = Articulo.new(articulo_params)

      unless @articulo.save
        render json: @articulo.errors, status: :unprocessable_entity
      else
        set_contenido_referencia
        # set_secuencia
      end
    end
  end

  def set_contenido_referencia
    if @articulo.contenido_articulos.length <= 1
      set_secuencia
      return
    end

    firstContenido = @articulo.contenido_articulos.first

    lastContenido = @articulo.contenido_articulos.last

    unless lastContenido.update({ referencia: firstContenido.id })
      render json: lastContenido.errors, status: :unprocessable_entity
    else
      set_secuencia
    end
  end

  def set_secuencia
    lastArticulo = @articulo
    @codigoSiguiente = "%05d" % lastArticulo["id"].to_s

    if lastArticulo.update({ codigo: @codigoSiguiente })
      seguir = addHistorico(@articulo)

      if seguir[:error] == false
        render json: @articulo, status: :created, location: @articulo
      else
        return render json: { error: seguir[:msg], msg: "error creando historico" }, status: :unprocessable_entity
      end
    else
      render json: lastArticulo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articulos/1
  def update
    Articulo.transaction do
      @ant_articulo = @articulo

      if articulo_params["existencia"] == @ant_articulo["existencia"]
        seguir = addHistorico(@ant_articulo)
      else
        seguir = { error: false, msg: "" }
      end

      if seguir[:error] == false
        newArticulo = {
          "suplidor_id": articulo_params["suplidor_id"],
          "marca_id": articulo_params["marca_id"],
          "modelo_id": articulo_params["modelo_id"],
          "tipo_articulo_id": articulo_params["tipo_articulo_id"],
          "identificador": articulo_params["identificador"],
          "nombre": articulo_params["nombre"],
          "color": articulo_params["color"],
          "costo_principal": articulo_params["costo_principal"],
          "precio_principal": articulo_params["precio_principal"],
          "existencia": articulo_params["existencia"],
          "codigo": @articulo["codigo"],
          "medida": articulo_params["medida"],
          "is_detallable": articulo_params["is_detallable"],
          "aviso_existencia": articulo_params["aviso_existencia"],
          "medida_alerta": articulo_params["medida_alerta"],
          "estado": articulo_params["estado"],
          "is_combo": articulo_params["is_combo"],
        }

        if @articulo.update(newArticulo)
          articulo_params["contenido_articulos_attributes"].each do |contenido|
            content = ContenidoArticulo.find_by_id(contenido["id"])

            contenidoCompleto = ContenidoArticulo.where({ articulo_id: @articulo["id"] })

            newContenido = {
              "costo": contenido["costo"],
              "precio": contenido["precio"],
              "cantidad": contenido["cantidad"],
              "medida": contenido["medida"],
              "condicion": contenido["condicion"],
              "calcular_itbis": contenido["calcular_itbis"],
            }

            if contenidoCompleto == [] || contenidoCompleto == nil
              newContenido["articulo_id"] = @articulo["id"]
              new_contenido = ContenidoArticulo.new(newContenido)
              if new_contenido.save
                unless @articulo.contenido_articulos.length <= 1
                  firstContenido = @articulo.contenido_articulos.first

                  lastContenido = @articulo.contenido_articulos.last

                  unless lastContenido.update({ referencia: firstContenido.id })
                    render json: lastContenido.errors, status: :unprocessable_entity
                  end
                end
              else
                return render json: new_contenido.errors, status: :unprocessable_entity
              end
            else
              unless content.update(newContenido)
                return render json: { error: content.errors, msg: "Error editando contenido de articulo" }, status: :unprocessable_entity
              end
            end
          end

          @obj = articulo_params

          @obj["id"] = @articulo["id"]
          @obj["codigo"] = @articulo["codigo"]

          render json: @obj, status: 200
        else
          render json: @articulo.errors, status: :unprocessable_entity
        end
      else
        return render json: { error: seguir[:msg], msg: "error creando historico" }, status: :unprocessable_entity
      end
    end
  end

  def deleteArticulo
    if Articulo.delete_articulo(params[:id])
      render json: { msg: "Articulo borrado", status: 200 }
    else
      render json: { msg: "error borrando articulo.", status: :unprocessable_entity }
    end
  end

  def addHistorico(anterior)
    @ant = anterior

    obj = {
      "articulo_id": @ant["id"],
      "suplidor_id": @ant["suplidor_id"],
      "marca_id": @ant["marca_id"],
      "modelo_id": @ant["modelo_id"],
      "tipo_articulo_id": @ant["tipo_articulo_id"],
      "identificador": @ant["identificador"],
      "nombre": @ant["nombre"],
      "color": @ant["color"],
      "costo_principal": @ant["costo_principal"],
      "precio_principal": @ant["precio_principal"],
      "existencia": @ant["existencia"],
      "codigo": @ant["codigo"],
      "medida": @ant["medida"],
      "is_detallable": @ant["is_detallable"],
      "aviso_existencia": @ant["aviso_existencia"],
      "medida_alerta": @ant["medida_alerta"],
      "agotado": @ant["agotado"],
      "estado": @ant["estado"],
      "is_combo": @ant["is_combo"],
      "user_id": @usuario_id,

    }

    @ant.contenido_articulos.each do |contenido|
      if contenido["referencia"]
        obj["medida_hijo"] = contenido["medida"]
        obj["costo_hijo"] = contenido["costo"]
        obj["precio_hijo"] = contenido["precio"]
        obj["cantidad_hijo"] = contenido["cantidad"]
        obj["referencia_hijo"] = contenido["referencia"]
      else
        obj["medida_padre"] = contenido["medida"]
        obj["costo_padre"] = contenido["costo"]
        obj["precio_padre"] = contenido["precio"]
        obj["cantidad_padre"] = contenido["cantidad"]
        obj["referencia_padre"] = contenido["referencia"]
      end
    end

    numeroDeRegistros = HistoricoArticulo.all.count
    if numeroDeRegistros == 0
      secu = 0
    else
      lastmantenimiento = HistoricoArticulo.last
      secu = lastmantenimiento["secuencia"]
    end

    if secu == nil
      secu = 0
    end

    @secue = secu + 1
    obj["secuencia"] = @secue

    historico = HistoricoArticulo.new(obj)

    unless historico.save
      return { error: true, msg: historico.errors, status: :unprocessable_entity }
    else
      return { error: false, msg: "", status: 200 }
    end
  end

  # DELETE /articulos/1
  def destroy
    @articulo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_articulo
    @usuario_id = params["user_id"]
    @articulo = Articulo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def articulo_params
    params.require(:articulo).permit(:suplidor_id, :marca_id, :modelo_id, :tipo_articulo_id, :identificador, :nombre, :color,
                                     :costo_principal, :precio_principal, :existencia, :codigo, :medida, :is_detallable,
                                     :aviso_existencia, :medida_alerta, :estado, :is_combo, :unico, :agotado, :user_id,
                                     contenido_articulos_attributes: [:id, :articulo_id, :referencia, :costo, :precio, :cantidad, :medida, :condicion, :calcular_itbis])
  end
end
