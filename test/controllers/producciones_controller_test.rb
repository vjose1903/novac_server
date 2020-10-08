require 'test_helper'

class ProduccionesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @produccion = producciones(:one)
  end

  test "should get index" do
    get producciones_url, as: :json
    assert_response :success
  end

  test "should create produccion" do
    assert_difference('Produccion.count') do
      post producciones_url, params: { produccion: { fecha_equivalente: @produccion.fecha_equivalente, numero: @produccion.numero, user_id: @produccion.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show produccion" do
    get produccion_url(@produccion), as: :json
    assert_response :success
  end

  test "should update produccion" do
    patch produccion_url(@produccion), params: { produccion: { fecha_equivalente: @produccion.fecha_equivalente, numero: @produccion.numero, user_id: @produccion.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy produccion" do
    assert_difference('Produccion.count', -1) do
      delete produccion_url(@produccion), as: :json
    end

    assert_response 204
  end
end
