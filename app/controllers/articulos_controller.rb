class ArticulosController < ApplicationController
  before_action :set_articulo, only: [:show, :update, :destroy]

  # GET /articulos
  def index
    # @articulos = Articulo.all
    @articulos = []
    Articulo.all.each do |articulo|
      if articulo["estado"] == true
        @articulos.push(Articulo.parseal(articulo))
      end
    end
    render json: @articulos
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
        articulos_.push(Articulo.parseal(art))
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
            if arti["is_combo"]
              att["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: arti["id"] })
            end
          end

          res = { data: article, status: 200 }
          # res = { data: articulos_.to_a.my_paginate(page, per_page), status: 200 }
        else
          articulos_.each do |arti|
            arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
            if arti["is_combo"]
              att["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: arti["id"] })
            end
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

  def getArticulosFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    articulos = Articulo.filtrarArticulo(arg)
    puts articulos.to_json
    articulos_ = Articulo.parsearArticulosFiltro(articulos)

    res = []

    if paginado
      res = Articulo.agruparDesagruparFiltro(arg, articulos_, page, per_page)
    else
      res = articulos_
      res.each do |arti|
        arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
        arti["contenido"] = Articulo.calcularContenidos(arti["contenido_articulos"], arti)
        arti["cantidades"] = Articulo.calcularCantidades(arti["contenido_articulos"], arti)
      end
    end

    render json: res
  end

  # def getArticulosFiltrados
  #   arg = params["arg"]

  #   page = params["page"]
  #   per_page = params["per_page"]
  #   paginado = params["paginado"] === "true" ? true : false

  #   articulos = Articulo.filtrarArticulo(arg)

  #   articulos_ = Articulo.parsearArticulosFiltro(articulos)

  #   res = []

  #   if paginado
  #     res = articulos_.to_a.my_paginate(page, per_page)
  #     res[:data].each do |arti|
  #       if arti["is_combo"]
  #         arti["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: arti["id"] })
  #       end
  #     end
  #   else
  #     res = articulos_
  #     res.each do |arti|
  #       if arti["is_combo"]
  #         arti["formulas_productos_terminados"] = FormulasProductosTerminado.where({ articulo_id: arti["id"] })
  #       end
  #     end
  #   end

  #   render json: res
  # end

  # GET /articulos/1
  def show
    articulo = Articulo.parseal(@articulo)
    if articulo["estado"] == false
      articulo = { "nombre": "Este articulo esta desactivado." }
    end
    render json: articulo
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
      @articulo.destroy
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
        @articulo.destroy
        return render json: { error: seguir[:msg], msg: "error creando historico" }, status: :unprocessable_entity
      end
    else
      @articulo.destroy
      render json: lastArticulo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articulos/1
  def update
    Articulo.transaction do
      @ant_articulo = Articulo.parseal(@articulo)
      if articulo_params["existencia"] == @ant_articulo["existencia"]
        seguir = addHistorico(@ant_articulo)
      else
        seguir = { error: true, msg: "" }
      end
      if !seguir[:error]
        newArticulo = {
          "tipo_articulo_id": articulo_params["tipo_articulo_id"],
          "nombre": articulo_params["nombre"],
          "costo_principal": articulo_params["costo_principal"],
          "precio_principal": articulo_params["precio_principal"],
          "existencia": articulo_params["existencia"],
          "imagen_id": articulo_params["imagen_id"],
          "medida": articulo_params["medida"],
          "is_detallable": articulo_params["is_detallable"],
          "medida_alerta": articulo_params["medida_alerta"],
          "aviso_existencia": articulo_params["aviso_existencia"],
          "otros_costos": articulo_params["otros_costos"],
          "calcular_itbis": articulo_params["calcular_itbis"],
          "vendido_en": articulo_params["vendido_en"],
          "codigo": @articulo["codigo"],
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

          if articulo_params["is_combo"]
            seguirFormula = true
            articulo_params["formulas_productos_terminados_attributes"].each do |articulo_formula|
              form = FormulasProductosTerminado.find_by_id(articulo_formula["id"])
              formulaObj = {
                "articulo_id": @articulo["id"],
                "articulo_combo": articulo_formula["articulo_combo"],
                "cantidad": articulo_formula["cantidad"],
                "costo": articulo_formula["costo"],
                "precio": articulo_formula["precio"],
              }

              if form == nil
                new_formula = FormulasProductosTerminado.new(formulaObj)

                FormulasProductosTerminado.transaction do
                  unless new_formula.save
                    seguirFormula = false
                    return render json: { error: new_formula.errors, msg: "Error agregando formula de articulo" }, status: 400
                  end
                end
              else
                FormulasProductosTerminado.transaction do
                  unless form.update(formulaObj)
                    seguirFormula = false
                    return render json: { error: form.errors, msg: "Error editando formula de articulo" }, status: 400
                  end
                end
              end
            end

            if seguirFormula
              render json: @obj
            else
              return render json: { msg: "Error editando formula de articulo, << luego del seguir >>" }, status: 400
            end
          else
            render json: @obj
          end
        else
          return render json: @articulo.errors, status: 400
        end
      else
        return render json: { error: seguir[:msg], msg: "error creando historico" }, status: seguir[:status]
      end
    end
  end

  def addHistorico(anterior)
    Articulo.transaction do
      @ant = anterior
      obj = { "articulo_id": anterior["id"],
             "user_id": @usuario_id,
             "ant_nombre": anterior["nombre"],
             "ant_tipoArticuloId": anterior["tipo_articulo_id"],
             "ant_tipoArticulo": anterior["descripcion"],
             "ant_medida": anterior["medida"],
             "ant_medidaAlerta": anterior["medida_alerta"],
             "ant_costoP": anterior["costo_principal"],
             "ant_precioP": anterior["precio_principal"],
             "ant_alertaExistencia": anterior["aviso_existencia"],
             "ant_isDetallable": anterior["is_detallable"],
             "ant_calcularItbis": anterior["calcular_itbis"],
             "ant_isCombo": anterior["is_combo"],
             #  "vendido_en": anterior["vendido_en"],
             "ant_otrosCostos": anterior["otros_costos"] }

      anterior["contenido_articulos"].to_a.each do |contenido|
        if contenido["referencia"]
          obj["ant_medidaHijo"] = contenido["medida"]
          obj["ant_costoHijo"] = contenido["costo"]
          obj["ant_precioHijo"] = contenido["precio"]
          obj["ant_cantidadHijo"] = contenido["cantidad"]
          obj["ant_idHijo"] = contenido["id"]
          obj["ant_referenciaHijo"] = contenido["referencia"]
        else
          obj["ant_medidaPadre"] = contenido["medida"]
          obj["ant_costoPadre"] = contenido["costo"]
          obj["ant_precioPadre"] = contenido["precio"]
          obj["ant_cantidadPadre"] = contenido["cantidad"]
          obj["ant_idPadre"] = contenido["id"]
          obj["ant_referenciaPadre"] = contenido["referencia"]
        end
      end

      numeroDeRegistros = MantenimientoArticulo.all.count
      if numeroDeRegistros == 0
        secu = 0
      else
        lastmantenimiento = MantenimientoArticulo.last
        secu = lastmantenimiento["id"]
      end

      if secu == nil
        secu = 0
      end

      @secue = secu + 1
      obj["secuencia"] = @secue

      historico = MantenimientoArticulo.new(obj)

      unless historico.save
        return { error: true, msg: historico.errors, status: :unprocessable_entity }
      else
        res = false

        if @ant["is_combo"]
          @ant["formulas_productos_terminados"].each do |form|
            formulaObj = {
              "articulo_id": form["articulo_id"],
              "articulo_combo": form["articulo_combo"],
              "cantidad": form["cantidad"],
              "costo": form["costo"],
              "precio": form["precio"],
              "secuencia": @secue,
            }

            @historicoF = MantenimientoFormula.new(formulaObj)

            unless @historicoF.save
              res = true
            end
          end
        end

        if res == true
          return { error: true, msg: @historicoF.errors, status: :unprocessable_entity }
        else
          return { error: false, msg: "", status: 200 }
        end
      end
    end
  end

  # DELETE /articulos/1
  def destroy
    @articulo.destroy
  end

  def deleteArticulo
    if Articulo.delete_articulo(params[:id])
      render json: { msg: "Articulo borrado" }
    else
      render json: { msg: "error borrando articulo." }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_articulo
    @usuario_id = params["user_id"]

    @articulo = Articulo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def articulo_params
    params.require(:articulo).permit(:tipo_articulo_id, :nombre, :estado, :costo_principal, :precio_principal, :medida_alerta, :existencia, :codigo, :fecha_ingreso, :medida, :is_detallable,
                                     :aviso_existencia, :calcular_itbis, :is_combo, :otros_costos, :vendido_en,
                                     imagen_attributes: [:file_name, :base_64, :path],
                                     contenido_articulos_attributes: [:articulo_id, :referencia, :costo, :precio, :cantidad, :medida, :id, :condicion, :calcular_itbis, :secuencia],
                                     formulas_productos_terminados_attributes: [:articulo_id, :cantidad, :costo, :_destroy, :articulo_combo, :id, :precio])
  end
end
