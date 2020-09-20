class SecuenciaComprobante < ApplicationRecord
  def self.get_paquete_rnc_by_estado(tipo_factura_id, estado)
    puts " -------------- Inicio get_paquete_rnc_by_estado -------------- "

    tipoFac = TipoFactura.find_by_id(tipo_factura_id)

    if tipoFac["referencia"] == "00" || tipoFac["referencia"] == 0
      @secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(tipo_factura_id)
      secuencia_factura = @secuencia_factura

      secuencia_factura["is_paquete"] = false

      return { :error => false, :msg => "factura sin comprobante no necesitan paquetes", :body => secuencia_factura, :status => 200 }
    elsif tipoFac["referencia"] == "02" || tipoFac["referencia"] == 2
      @secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(tipo_factura_id)
      secuencia_factura = @secuencia_factura.attributes
      secuencia_factura["is_paquete"] = false

      return { :error => false, :msg => "factura de consumo no necesitan paquetes", :body => secuencia_factura, :status => 200 }
    else
      select_ = "select *"
      from_ = "from secuencia_comprobantes"
      where_ = "where estado = #{estado} AND usado = #{false} AND tipo_factura_id = #{tipo_factura_id}"
      order_ = "ORDER BY created_at ASC LIMIT 1"
      query = "#{select_} #{from_} #{where_} #{order_}"
      paquete = my_query(query)[0]
      paquete["is_paquete"] = true

      if paquete == [] || paquete == nil
        existen_siguientes = ver_si_existen_paquetes_posteriores(tipo_factura_id)
        if existen_siguientes[:bool]
          activar_nuevo_paquete(tipo_factura_id)
          puts " -------------- fin get_paquete_rnc_by_estado -------------- "
          return { :error => false, :msg => "correcto, siguiente paquete", :body => existen_siguientes[:Paquete], :status => 200 } #respuesta correcta
        end

        existen_anteriores = ver_si_existen_paquetes_previos(tipo_factura_id)
        if existen_anteriores
          puts " -------------- fin get_paquete_rnc_by_estado -------------- "
          return { :error => true, :msg => "Los paquete de comprobantes para #{tipoFac["descripcion"]}, se han agotado debe de comprar mas.", :body => [], :status => 404 }
        else
          puts " -------------- fin get_paquete_rnc_by_estado -------------- "
          return { :error => true, :msg => "No se han solicitado paquetes de comprobantes para #{tipoFac["descripcion"]}", :body => [], :status => 404 }
        end
        #
      elsif paquete["secuencia"] == paquete["hasta"]
        puts " -------------- fin get_paquete_rnc_by_estado -------------- "
        return { :error => false, :msg => "Ultimo comprobante de este paquete", :body => paquete, :status => 200 }
        #
      elsif paquete["secuencia"] > paquete["hasta"]
        select_ = "select *"
        from_ = "from secuencia_comprobantes"
        where_ = "where estado = #{false} AND usado = #{false} AND tipo_factura_id = #{tipo_factura_id}"
        order_ = "ORDER BY created_at ASC LIMIT 1"
        newQuery = "#{select_} #{from_} #{where_} #{order_}"
        nuevoPaquete = my_query(newQuery)[0]
        nuevoPaquete["is_paquete"] = true

        if nuevoPaquete == [] || nuevoPaquete == nil
          puts " -------------- fin get_paquete_rnc_by_estado -------------- "
          return { :error => true, :msg => "Los paquete de comprobantes para #{tipoFac["descripcion"]}, se han agotado debe de comprar mas.", :body => [], :status => 404 }
        else
          # return { :error => true, :msg => "Existen errores en la base de datos, secuencia no pertene al paquete de NCF seleccionado", :body => [], :status => 404 }
          puts " -------------- fin get_paquete_rnc_by_estado -------------- "
          return { :error => false, :msg => "siguiente paquete", :body => nuevoPaquete, :status => 200 }
        end
        #
      else
        puts " -------------- fin get_paquete_rnc_by_estado -------------- "
        return { :error => false, :msg => "correcto", :body => paquete, :status => 200 }
      end
    end
  end

  # ============================================================================================================================================================

  def self.filtrar_ncf(arg)
    puts " -------------- Inicio filtrar_ncf -------------- "
    puts "######## #{arg}".blue

    arg = arg === " " ? "" : arg

    select_ = "SELECT sc.*"
    from_ = "FROM secuencia_comprobantes sc"
    joins_ = "inner join tipo_facturas tf on sc.tipo_factura_id = tf.id"
    where_ = "where lower(tf.descripcion  || ' ' || desde || ' ' || hasta) like lower('%#{arg}%')"
    order_ = "ORDER BY sc.id ASC"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    puts " -------------- fin filtrar_ncf -------------- "
    my_query(query)
  end

  # ============================================================================================================================================================
  def self.get_paquetes_por_activar(tipo_factura_id)
    puts " -------------- Inicio get_paquetes_por_activar -------------- "
    tipoFac = TipoFactura.find_by_id(tipo_factura_id)

    select_ = "select *"
    from_ = "from secuencia_comprobantes"
    where_ = "where estado = #{false} AND usado != #{true} AND tipo_factura_id = #{tipo_factura_id}"
    order_ = "ORDER BY created_at ASC LIMIT 1"
    newQuery = "#{select_} #{from_} #{where_} #{order_}"
    nuevoPaquete = my_query(newQuery)[0]

    if nuevoPaquete == [] || nuevoPaquete == nil
      puts " -------------- fin get_paquetes_por_activar -------------- "
      return { :continuar => false }
    else
      puts " -------------- fin get_paquetes_por_activar -------------- "
      return { :continuar => true, :body => nuevoPaquete }
    end
  end

  # ============================================================================================================================================================
  def self.aumentar_secuencia_comprobante(paquete_id)
    puts " -------------- inicio aumentar_secuencia_comprobante -------------- "
    paquete = SecuenciaComprobante.find_by_id(paquete_id)

    sigue = { error: false, msg: "" }

    if paquete["secuencia"] == paquete["hasta"]
      nuevoPac = get_paquetes_por_activar(paquete["tipo_factura_id"])

      if nuevoPac[:continuar]
        newPac = SecuenciaComprobante.find_by_id(nuevoPac[:body]["id"])
        unless newPac.update({ estado: true })
          sigue = { error: true, msg: newPac.errors }
        end
      end

      paquete.update({ estado: false, usado: true })
    else
      unless paquete.update({ secuencia: paquete[:secuencia] + 1 })
        sigue = { error: true, msg: paquete.errors }
      end
    end
    puts " -------------- fin aumentar_secuencia_comprobante -------------- "
    return sigue
  end

  # ============================================================================================================================================================
  def self.activar_nuevo_paquete(tipo_factura)
    puts " -------------- inicio activar_nuevo_paquete -------------- "
    sigue = true
    nuevoPac = get_paquetes_por_activar(tipo_factura)
    if nuevoPac[:continuar]
      newPac = SecuenciaComprobante.find_by_id(nuevoPac[:body]["id"])
      unless newPac.update({ estado: true })
        sigue = false
      end
    end
    puts " -------------- fin activar_nuevo_paquete -------------- "
    return sigue
  end

  # ============================================================================================================================================================
  def self.ver_si_existen_paquetes_previos(tipo_factura_id)
    puts " -------------- inicio ver_si_existen_paquetes_previos -------------- "
    select_ = "select *"
    from_ = "from secuencia_comprobantes"
    where_ = "where estado = false AND usado = true AND tipo_factura_id = #{tipo_factura_id}"
    query = "#{select_} #{from_} #{where_}"
    paquete = my_query(query)[0]

    if paquete == [] || paquete == nil
      puts " -------------- fin ver_si_existen_paquetes_previos -------------- "
      return false
    else
      puts " -------------- fin ver_si_existen_paquetes_previos -------------- "
      return true
    end
  end

  # ============================================================================================================================================================
  def self.ver_si_existen_paquetes_posteriores(tipo_factura_id)
    puts " -------------- inicio ver_si_existen_paquetes_posteriores -------------- "

    select_ = "select *"
    from_ = "from secuencia_comprobantes"
    where_ = "where estado = false AND usado = false AND tipo_factura_id = #{tipo_factura_id}"
    order_ = "ORDER BY created_at ASC LIMIT 1"
    query = "#{select_} #{from_} #{where_} #{order_}"
    paquete = my_query(query)[0]
    paquete["is_paquete"] = true

    if paquete == [] || paquete == nil
      puts " -------------- fin ver_si_existen_paquetes_posteriores -------------- "
      return { :bool => false, :Paquete => {} }
    else
      puts " -------------- fin ver_si_existen_paquetes_posteriores -------------- "
      return { :bool => true, :Paquete => paquete }
    end
  end

  # ============================================================================================================================================================
  def self.validar_rango(tipo_factura_id, paquete_ingresando)
    puts " -------------- inicio validar_rango -------------- "

    select_ = "select *"
    from_ = "from secuencia_comprobantes"
    where_ = "where tipo_factura_id = #{tipo_factura_id}"
    order_ = "ORDER BY created_at ASC"
    query = "#{select_} #{from_} #{where_} #{order_}"
    paquetes_registrados = my_query(query)

    puts paquetes_registrados

    paquetes_registrados.each do |paquete|
      if paquete_ingresando["desde"] <= paquete["hasta"]
        puts " -------------- fin validar_rango -------------- "
        return { :error => true, :msg => "Numeros introducidos existen en el paquete con el codigo ##{("%05d" % paquete["id"])}.", :body => {}, :status => 400 }
        break
      end
    end
    puts " -------------- fin validar_rango -------------- "
    return { :error => false }
  end

  # ============================================================================================================================================================

end
