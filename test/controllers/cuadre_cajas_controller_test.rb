require 'test_helper'

class CuadreCajasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cuadre_caja = cuadre_cajas(:one)
    @principal_divisa = Divisa.create!(nombre: 'Peso controller test', simbolo: 'DOP', estado: true, is_principal: true, current_tasa: 1)
  end

  test "should get index" do
    get cuadre_cajas_url, as: :json
    assert_response :success
  end

  test "should create cuadre_caja" do
    assert_difference('CuadreCaja.count') do
      post cuadre_cajas_url, params: detailed_params('2026-07-26'), as: :json
    end

    assert_response :success
  end

  test "should prepare cuadre without creating it" do
    assert_no_difference('CuadreCaja.count') do
      post prepare_cuadre_cajas_url, params: { closing_date: '2026-07-27' }, as: :json
    end

    assert_response :success
  end

  test "should show cuadre_caja" do
    get cuadre_caja_url(@cuadre_caja), as: :json
    assert_response :success
  end

  test "should update cuadre_caja" do
    patch cuadre_caja_url(@cuadre_caja), params: detailed_params(@cuadre_caja.closing_date), as: :json
    assert_response :success
  end

  test "should destroy cuadre_caja" do
    assert_difference('CuadreCaja.count', -1) do
      delete cuadre_caja_url(@cuadre_caja), as: :json
    end

    assert_response 204
  end

  private

  def detailed_params(closing_date)
    {
      cuadre_caja: {
        closing_date: closing_date,
        user_id: @cuadre_caja.user_id,
        denominaciones: [
          { denomination_type: 'bill', divisa_id: @principal_divisa.id, denomination_value: 100, quantity: 1 }
        ],
        movimientos: [
          { movement_group: 'other_payment_methods', payment_method: 'card', description: 'Tarjeta', amount: 100 }
        ]
      }
    }
  end
end
