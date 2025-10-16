require "test_helper"

class NotasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @nota = notas(:one)
  end

  test "should get index" do
    get notas_url, as: :json
    assert_response :success
  end

  test "should create nota" do
    assert_difference('Nota.count') do
      post notas_url, params: { nota: { cliente_id: @nota.cliente_id, estado: @nota.estado, fecha_equivalente: @nota.fecha_equivalente, identificador: @nota.identificador, numero_comprobante: @nota.numero_comprobante, numero_documento: @nota.numero_documento, tipo_factura_id: @nota.tipo_factura_id, total: @nota.total, user_id: @nota.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show nota" do
    get nota_url(@nota), as: :json
    assert_response :success
  end

  test "should update nota" do
    patch nota_url(@nota), params: { nota: { cliente_id: @nota.cliente_id, estado: @nota.estado, fecha_equivalente: @nota.fecha_equivalente, identificador: @nota.identificador, numero_comprobante: @nota.numero_comprobante, numero_documento: @nota.numero_documento, tipo_factura_id: @nota.tipo_factura_id, total: @nota.total, user_id: @nota.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy nota" do
    assert_difference('Nota.count', -1) do
      delete nota_url(@nota), as: :json
    end

    assert_response 204
  end
end
