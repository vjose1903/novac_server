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
    else
      res = articulos_
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
          res = { data: articulos_.to_a.my_paginate(page, per_page), status: 200 }
        else
          res = { data: articulos_, status: 200 }
        end
      end
    else
      res = @articulos[0].nil? ? { data: { msg: "No existe articulo con el codigo introducido." }, status: :unprocessable_entity } : { data: Articulo.parsearArticulos(@articulos[0]), status: 200 }
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
        set_secuencia
      end
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
        puts "error creando historico".red
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

      puts @ant_articulo.to_json
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
          render json: @articulo
        else
          render json: @articulo.errors, status: :unprocessable_entity
        end
      else
        puts "error creando historico".red
        return render json: { error: seguir[:msg], msg: "error creando historico" }, status: :unprocessable_entity
      end
    end
  end

  def deleteArticulo
    if Articulo.delete_articulo(params[:id])
      render json: { msg: "Articulo borrado" }
    else
      render json: { msg: "error borrando articulo." }
    end
  end

  def addHistorico(anterior)
    @ant = anterior
    obj = {
      "articulo_id": anterior["id"],
      "suplidor_id": anterior["suplidor_id"],
      "marca_id": anterior["marca_id"],
      "modelo_id": anterior["modelo_id"],
      "tipo_articulo_id": anterior["tipo_articulo_id"],
      "identificador": anterior["identificador"],
      "nombre": anterior["nombre"],
      "color": anterior["color"],
      "costo_principal": anterior["costo_principal"],
      "precio_principal": anterior["precio_principal"],
      "existencia": anterior["existencia"],
      "codigo": anterior["codigo"],
      "medida": anterior["medida"],
      "is_detallable": anterior["is_detallable"],
      "aviso_existencia": anterior["aviso_existencia"],
      "medida_alerta": anterior["medida_alerta"],
      "agotado": anterior["agotado"],
      "estado": anterior["estado"],
      "is_combo": anterior["is_combo"],
      "user_id": @usuario_id,

    }

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
      return { error: true, msg: historico.errors }
    else
      return { error: false, msg: "" }
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
                                     :aviso_existencia, :medida_alerta, :estado, :is_combo, :unico, :agotado, :user_id)
  end
end
