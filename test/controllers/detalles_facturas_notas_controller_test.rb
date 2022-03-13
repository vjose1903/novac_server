require "test_helper"

class DetallesFacturasNotasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @detalle_factura_nota = detalles_facturas_notas(:one)
  end

  test "should get index" do
    get detalles_facturas_notas_url, as: :json
    assert_response :success
  end

  test "should create detalle_factura_nota" do
    assert_difference('DetalleFacturaNota.count') do
      post detalles_facturas_notas_url, params: { detalle_factura_nota: { articulo_id: @detalle_factura_nota.articulo_id, cantidad: @detalle_factura_nota.cantidad, cantidad_en_unidades: @detalle_factura_nota.cantidad_en_unidades, costo: @detalle_factura_nota.costo, descuento: @detalle_factura_nota.descuento, detalle_factura_id: @detalle_factura_nota.detalle_factura_id, factura_aplicada_id: @detalle_factura_nota.factura_aplicada_id, itbis: @detalle_factura_nota.itbis, precio: @detalle_factura_nota.precio, total: @detalle_factura_nota.total, unidad: @detalle_factura_nota.unidad } }, as: :json
    end

    assert_response 201
  end

  test "should show detalle_factura_nota" do
    get detalle_factura_nota_url(@detalle_factura_nota), as: :json
    assert_response :success
  end

  test "should update detalle_factura_nota" do
    patch detalle_factura_nota_url(@detalle_factura_nota), params: { detalle_factura_nota: { articulo_id: @detalle_factura_nota.articulo_id, cantidad: @detalle_factura_nota.cantidad, cantidad_en_unidades: @detalle_factura_nota.cantidad_en_unidades, costo: @detalle_factura_nota.costo, descuento: @detalle_factura_nota.descuento, detalle_factura_id: @detalle_factura_nota.detalle_factura_id, factura_aplicada_id: @detalle_factura_nota.factura_aplicada_id, itbis: @detalle_factura_nota.itbis, precio: @detalle_factura_nota.precio, total: @detalle_factura_nota.total, unidad: @detalle_factura_nota.unidad } }, as: :json
    assert_response 200
  end

  test "should destroy detalle_factura_nota" do
    assert_difference('DetalleFacturaNota.count', -1) do
      delete detalle_factura_nota_url(@detalle_factura_nota), as: :json
    end

    assert_response 204
  end
end
