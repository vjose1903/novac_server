class MovimientosInventario < ApplicationRecord
  def self.movimientos_de_inventario(accion, articulo, medida, cantidad)
    if cantidad == nil
      cantidad = 0
    end

    cantPrincipal = 1
    cantPadre = 0
    cantHijo = 1
    maxCant = 1

    medidaEs = ""
    if medida == articulo["medida"]
      medidaEs = "principal"
    end

    if articulo["contenido_articulos"].length === 0
      cantPrincipal = 1
    else
      articulo["contenido_articulos"].each do |contenido|
        cantPrincipal = contenido["cantidad"] * cantPrincipal

        if contenido["condicion"] == "hijo"
          cantPadre = contenido["cantidad"]
        end
        if contenido["condicion"] == "padre"
          if contenido["medida"] == "Libra" || contenido["medida"] == "Unidad"
            cantPadre = 1
          end

          if medida == contenido["medida"]
            medidaEs = "padre"
          end
        else
          if medida == contenido["medida"]
            medidaEs = "hijo"
          end
        end
      end
    end

    if medidaEs == "principal"
      maxCant = cantPrincipal
    elsif medidaEs == "padre"
      maxCant = cantPadre
    else
      maxCant = cantHijo
    end

    cant = (maxCant * cantidad)

    if accion == "salida"
      # --------- SALIDA ---------

      movimiento = Articulo.find_by_id(articulo["id"])
      mov = (movimiento["existencia"] - cant)

      if movimiento.update({ existencia: mov })
        puts "::::::::::::::::::::::::::::::::::::::::::"
        puts "::::                                  ::::"
        puts "::::   SALIDA INVENTARIO EXITOSA      ::::"
        puts "::::                                  ::::"
        puts "::::::::::::::::::::::::::::::::::::::::::"
        return mov
      end
    else
      # --------- ENTRADA ---------
      movimiento = Articulo.find_by_id(articulo["id"])
      mov = (movimiento["existencia"] + cant)

      if movimiento.update({ existencia: mov })
        puts "::::::::::::::::::::::::::::::::::::::::::"
        puts "::::                                  ::::"
        puts "::::   ENTRADA INVENTARIO EXITOSA     ::::"
        puts "::::                                  ::::"
        puts "::::::::::::::::::::::::::::::::::::::::::"
        return mov
      end
    end
  end
end
