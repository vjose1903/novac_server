require 'test_helper'

class MovimientosInventariosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movimientos_inventario = movimientos_inventarios(:one)
  end

  test "should get index" do
    get movimientos_inventarios_url, as: :json
    assert_response :success
  end

  test "should create movimientos_inventario" do
    assert_difference('MovimientosInventario.count') do
      post movimientos_inventarios_url, params: { movimientos_inventario: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show movimientos_inventario" do
    get movimientos_inventario_url(@movimientos_inventario), as: :json
    assert_response :success
  end

  test "should update movimientos_inventario" do
    patch movimientos_inventario_url(@movimientos_inventario), params: { movimientos_inventario: {  } }, as: :json
    assert_response 200
  end

  test "should destroy movimientos_inventario" do
    assert_difference('MovimientosInventario.count', -1) do
      delete movimientos_inventario_url(@movimientos_inventario), as: :json
    end

    assert_response 204
  end
end
