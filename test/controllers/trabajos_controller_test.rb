require 'test_helper'

class TrabajosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trabajo = trabajos(:one)
  end

  test "should get index" do
    get trabajos_url, as: :json
    assert_response :success
  end

  test "should create trabajo" do
    assert_difference('Trabajo.count') do
      post trabajos_url, params: { trabajo: { cliente_id: @trabajo.cliente_id, descripcion: @trabajo.descripcion, identificador: @trabajo.identificador, marca_id: @trabajo.marca_id, modelo_id: @trabajo.modelo_id, tiene_bateria: @trabajo.tiene_bateria, tipo_trabajo: @trabajo.tipo_trabajo } }, as: :json
    end

    assert_response 201
  end

  test "should show trabajo" do
    get trabajo_url(@trabajo), as: :json
    assert_response :success
  end

  test "should update trabajo" do
    patch trabajo_url(@trabajo), params: { trabajo: { cliente_id: @trabajo.cliente_id, descripcion: @trabajo.descripcion, identificador: @trabajo.identificador, marca_id: @trabajo.marca_id, modelo_id: @trabajo.modelo_id, tiene_bateria: @trabajo.tiene_bateria, tipo_trabajo: @trabajo.tipo_trabajo } }, as: :json
    assert_response 200
  end

  test "should destroy trabajo" do
    assert_difference('Trabajo.count', -1) do
      delete trabajo_url(@trabajo), as: :json
    end

    assert_response 204
  end
end
