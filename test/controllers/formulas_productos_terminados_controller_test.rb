require 'test_helper'

class FormulasProductosTerminadosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @formulas_productos_terminado = formulas_productos_terminados(:one)
  end

  test "should get index" do
    get formulas_productos_terminados_url, as: :json
    assert_response :success
  end

  test "should create formulas_productos_terminado" do
    assert_difference('FormulasProductosTerminado.count') do
      post formulas_productos_terminados_url, params: { formulas_productos_terminado: { articulos_id: @formulas_productos_terminado.articulos_id, cantidad: @formulas_productos_terminado.cantidad } }, as: :json
    end

    assert_response 201
  end

  test "should show formulas_productos_terminado" do
    get formulas_productos_terminado_url(@formulas_productos_terminado), as: :json
    assert_response :success
  end

  test "should update formulas_productos_terminado" do
    patch formulas_productos_terminado_url(@formulas_productos_terminado), params: { formulas_productos_terminado: { articulos_id: @formulas_productos_terminado.articulos_id, cantidad: @formulas_productos_terminado.cantidad } }, as: :json
    assert_response 200
  end

  test "should destroy formulas_productos_terminado" do
    assert_difference('FormulasProductosTerminado.count', -1) do
      delete formulas_productos_terminado_url(@formulas_productos_terminado), as: :json
    end

    assert_response 204
  end
end
