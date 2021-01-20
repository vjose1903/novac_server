class ArticulosController < ApplicationController
  before_action :set_articulo, only: [:show, :update, :destroy]

  # GET /articulos
  def index
    # @articulos = Articulo.all
    @articulos = []
    Articulo.all.each do |articulo|
      articuloSelect = MantenimientoArticulo.get_one_articulo_by_date(objeto["fecha_equivalente"], articuloSelect["id"])
      if articulo["estado"] == true
        @articulos.push(Articulo.parseal(articuloSelect))
      end
    end
    render json: @articulos
  end

  def getArticuloCosto
    id = params["id"]
    tipo = params["tipo"]
    articulo = Articulo.find_by_id(id)

    
    costo = articulo.costo_principal
    precio = articulo.precio_principal

    obj={
      id: articulo.id
    }

    if articulo["medida"] == "Quintal" || articulo["medida"] == "Saco"
      obj["costo"] = articulo.contenido_articulos[0]["costo"]
      obj["precio"] = articulo.contenido_articulos[0]["precio"]
    elsif articulo["medida"] == "Libra"
      obj["costo"] = articulo["costo_principal"]
      obj["precio"] = articulo["precio_principal"]
    end
    

    render json: obj
  end


  def getContenidos
    id = params["id"]
    articulo = Articulo.find_by_id(id)
    contenido = Articulo.calcularContenidos(articulo)
    

    render json: contenido
  end

  def checkIfExcede
    id = params["id"]
    cantidad = params["cantidad"]
    articulo = Articulo.find_by_id(id)

    if articulo.existencia.to_f < cantidad.to_f
      res = true
    else
      res = false
    end
    render json: { excede: res }
  end

  def getIngredientesFormula
    id = params["id"]
    articulo = Articulo.find_by_id(id)
    if articulo.nil?
      render json: { msg: "El articulo buscado no esta creado" }, status: 400
    elsif articulo.tipo_articulo_id != 3
      render json: { msg: "El tipo de articulo buscado no es un producto terminado" }, status: 400
    else
      formula = FormulasProductosTerminado.where({ articulo_id: articulo.id })
      ingredientes = []

      formula.each do |f|
        articulo_ingrediente = Articulo.find_by_id(f.articulo_combo)
        ingredientes.push({
          articulo_id: articulo_ingrediente.id,
          nombre: articulo_ingrediente.nombre,
          cantidad: f.cantidad,
          existencia: Articulo.calcularCantidades(articulo_ingrediente),
          contenido: Articulo.calcularContenidos(articulo_ingrediente),
        })
      end
      render json: ingredientes
    end
  end

  def getMateriasPrimas
    articulos = Articulo.where({ is_materia_prima: true })

    aArticulos = []
    articulos.each do |arti|
      obj = {}
      obj["nombre"] = arti["nombre"]
      obj["id"] = arti["id"]


      if arti["medida"] == "Quintal" || arti["medida"] == "Saco"
        obj["costo"] = arti.contenido_articulos[0]["costo"]
        obj["precio"] = arti.contenido_articulos[0]["precio"]
      elsif arti["medida"] == "Libra"
        obj["costo"] = arti["costo_principal"]
        obj["precio"] = arti["precio_principal"]
      end

      aArticulos.push(obj)
    end
    render json: aArticulos
  end

  def getcountArticulos
    cantidad = Articulo.countArticulos
    render json: cantidad
  end


  def getProductosTerminados
    articulos = Articulo.where({ tipo_articulo_id: 3 })

    aArticulos = []
    articulos.each do |arti|
      aArticulos.push(Articulo.parseal(arti))
    end
    render json: aArticulos
  end

  def getArticulosFiltrados
    arg = params["arg"]
    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false
    is_compra = params["is_compra"] === "true" ? true : false
    fecha = params["fecha"]
    tipo = params["tipo"]

    articulos_ = [] 
    articulos = Articulo.filtrarArticulo(arg, is_compra, tipo)

    res = []
    if paginado
      res = Articulo.agruparDesagruparFiltro(arg, articulos, page, per_page, fecha)

    else
      res = articulos
      res.each do |arti|
        arti["contenido_articulos"] = ContenidoArticulo.where({ articulo_id: arti["id"] })
        arti["contenido"] = Articulo.calcularContenidos(arti)
        arti["cantidades"] = Articulo.calcularCantidades(arti)
      end
    end




    render json: res
  end

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
      render json: lastContenido.errors, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    else
      set_secuencia
    end
  end

  def set_secuencia
    lastArticulo = @articulo
    @codigoSiguiente = "%05d" % lastArticulo["id"].to_s
    if lastArticulo.update({ codigo: @codigoSiguiente })
      arti = Articulo.parseal(@articulo)
      seguir = addHistorico(arti)

      if seguir[:error] == false
        render json: arti, status: :created, location: @articulo
      else
        render json: { error: seguir[:msg], msg: "error creando historico" }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    else
      render json: lastArticulo.errors, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    end
  end

  def checkSacoSistema(articulo_nuevo)
    res = { :error => false, :msg => '' }

    if @ant_articulo['nombre'] == 'Saco sistema'
      if articulo_nuevo["nombre"] != 'Saco sistema'
        return { :error => true, msg:'A este articulo no se le puede editar el nombre.' }
      elsif articulo_nuevo["medida"] != 'Unidad'
        return { :error => true, msg:'A este articulo no se le puede editar la medida en que se compra.' }
      elsif articulo_nuevo["vendido_en"] != 'Unidad'
        return { :error => true, msg:'A este articulo no se le puede editar la medida para vender.' }
      elsif articulo_nuevo["tipo_articulo_id"] != 4
        return { :error => true, msg:'A este articulo no se le puede editar el tipo de articulo.' }
      elsif articulo_nuevo["is_materia_prima"] 
        return { :error => true, msg:'Este articulo no se puede ser materia prima.' }
      else 
        return res
      end
    end
    return res
  end

  # PATCH/PUT /articulos/1
  def update
    Articulo.transaction do
      @ant_articulo = Articulo.parseal(@articulo)
     
      check_saco = checkSacoSistema(articulo_params)
      puts 'check_saco --> '.red + "#{check_saco}"
      if check_saco[:error]
        return render json: {msg: check_saco[:msg]}, status: 404
        raise ActiveRecord::Rollback
      end
      

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
          "is_materia_prima": articulo_params["is_materia_prima"],
          "calcular_saco": articulo_params["calcular_saco"],
          "codigo": @articulo["codigo"],
        }

        if @articulo.update(newArticulo)
          contenidosAdd = []
          articulo_params["contenido_articulos_attributes"].each do |contenido|
            contentido = ContenidoArticulo.find_by_id(contenido["id"])

            if contentido == [] || contentido == nil
              contentido={}
              contentido["articulo_id"] = @articulo["id"]
              contentido = ContenidoArticulo.new
            end

            contentido.costo = contenido["costo"]
            contentido.precio = contenido["precio"]
            contentido.cantidad = contenido["cantidad"]
            contentido.medida = contenido["medida"]
            contentido.condicion = contenido["condicion"]
            contentido.calcular_itbis = contenido["calcular_itbis"]

            contenidosAdd.push contentido
          end
          @articulo.contenido_articulos = contenidosAdd

          if @articulo.save!
            unless @articulo.contenido_articulos.length <= 1
              firstContenido = @articulo.contenido_articulos.first

              lastContenido = @articulo.contenido_articulos.last

              unless lastContenido.update({ referencia: firstContenido.id })
                return render json: lastContenido.errors, status: :unprocessable_entity
              end
            end
          else
            return render json: @articulo.errors, status: :unprocessable_entity
          end

          @obj = articulo_params

          @obj["id"] = @articulo["id"]
          @obj["codigo"] = @articulo["codigo"]

          if articulo_params["is_combo"]
            seguirFormula = true
            articulosAdd = []
            articulo_params["formulas_productos_terminados_attributes"].each do |articulo_formula|
              formula_ingrediente = FormulasProductosTerminado.find_by_id(articulo_formula["id"])

              if formula_ingrediente == nil
                formula_ingrediente = FormulasProductosTerminado.new
              end

              formula_ingrediente.articulo_id    = @articulo["id"]
              formula_ingrediente.articulo_combo = articulo_formula["articulo_combo"]
              formula_ingrediente.cantidad       = articulo_formula["cantidad"]
              formula_ingrediente.costo          = articulo_formula["costo"]
              formula_ingrediente.precio         = articulo_formula["precio"]

              articulosAdd.push formula_ingrediente
            end
            @articulo.formulas_productos_terminados = articulosAdd

            if @articulo.save!
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
             "ant_medida": anterior["medida"],
             "ant_medidaAlerta": anterior["medida_alerta"],
             "ant_costoP": anterior["costo_principal"],
             "ant_precioP": anterior["precio_principal"],
             "ant_alertaExistencia": anterior["aviso_existencia"],
             "ant_isDetallable": anterior["is_detallable"],
             "ant_calcularItbis": anterior["calcular_itbis"],
             "ant_isCombo": anterior["is_combo"],
             "vendido_en": anterior["vendido_en"],
             "is_materia_prima": anterior["is_materia_prima"],
             "ant_otrosCostos": anterior["otros_costos"] ,
             "calcular_saco": anterior["calcular_saco"] }

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
          @ant["formulas_productos_terminados"].to_a.each do |form|
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
                                     :aviso_existencia, :calcular_itbis, :is_combo, :otros_costos, :vendido_en, :is_materia_prima, :calcular_saco,
                                     imagen_attributes: [:file_name, :base_64, :path],
                                     contenido_articulos_attributes: [:articulo_id, :referencia, :costo, :precio, :cantidad, :medida, :id, :condicion, :calcular_itbis, :secuencia],
                                     formulas_productos_terminados_attributes: [:articulo_id, :cantidad, :costo, :_destroy, :articulo_combo, :id, :precio])
  end
end
