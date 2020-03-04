require 'test_helper'

class HistoricoProduccionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @historico_produccion = historico_produccions(:one)
  end

  test "should get index" do
    get historico_produccions_url, as: :json
    assert_response :success
  end

  test "should create historico_produccion" do
    assert_difference('HistoricoProduccion.count') do
      post historico_produccions_url, params: { historico_produccion: { articulo_id: @historico_produccion.articulo_id, cantidad: @historico_produccion.cantidad, medida: @historico_produccion.medida, user_id: @historico_produccion.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show historico_produccion" do
    get historico_produccion_url(@historico_produccion), as: :json
    assert_response :success
  end

  test "should update historico_produccion" do
    patch historico_produccion_url(@historico_produccion), params: { historico_produccion: { articulo_id: @historico_produccion.articulo_id, cantidad: @historico_produccion.cantidad, medida: @historico_produccion.medida, user_id: @historico_produccion.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy historico_produccion" do
    assert_difference('HistoricoProduccion.count', -1) do
      delete historico_produccion_url(@historico_produccion), as: :json
    end

    assert_response 204
  end
end
