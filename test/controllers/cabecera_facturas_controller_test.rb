require 'test_helper'

class CabeceraFacturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cabecera_factura = cabecera_facturas(:one)
  end

  test "should get index" do
    get cabecera_facturas_url, as: :json
    assert_response :success
  end

  test "should create cabecera_factura" do
    assert_difference('CabeceraFactura.count') do
      post cabecera_facturas_url, params: { cabecera_factura: { balance: @cabecera_factura.balance, cliente_id: @cabecera_factura.cliente_id, devuelta: @cabecera_factura.devuelta, forma_pago: @cabecera_factura.forma_pago, noCliente_direccion: @cabecera_factura.noCliente_direccion, noCliente_nombre: @cabecera_factura.noCliente_nombre, numero_factura: @cabecera_factura.numero_factura, pagada: @cabecera_factura.pagada, tiene_nota: @cabecera_factura.tiene_nota, total_factura: @cabecera_factura.total_factura, user_id: @cabecera_factura.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show cabecera_factura" do
    get cabecera_factura_url(@cabecera_factura), as: :json
    assert_response :success
  end

  test "should update cabecera_factura" do
    patch cabecera_factura_url(@cabecera_factura), params: { cabecera_factura: { balance: @cabecera_factura.balance, cliente_id: @cabecera_factura.cliente_id, devuelta: @cabecera_factura.devuelta, forma_pago: @cabecera_factura.forma_pago, noCliente_direccion: @cabecera_factura.noCliente_direccion, noCliente_nombre: @cabecera_factura.noCliente_nombre, numero_factura: @cabecera_factura.numero_factura, pagada: @cabecera_factura.pagada, tiene_nota: @cabecera_factura.tiene_nota, total_factura: @cabecera_factura.total_factura, user_id: @cabecera_factura.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy cabecera_factura" do
    assert_difference('CabeceraFactura.count', -1) do
      delete cabecera_factura_url(@cabecera_factura), as: :json
    end

    assert_response 204
  end
end
