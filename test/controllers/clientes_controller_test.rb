require 'test_helper'

class ClientesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cliente = clientes(:one)
  end

  test "should get index" do
    get clientes_url, as: :json
    assert_response :success
  end

  test "should create cliente" do
    assert_difference('Cliente.count') do
      post clientes_url, params: { cliente: { apellido: @cliente.apellido, direccion: @cliente.direccion, documento_de_identidad_id: @cliente.documento_de_identidad_id, imagen_id: @cliente.imagen_id, nombre: @cliente.nombre, sexo: @cliente.sexo, telefono: @cliente.telefono } }, as: :json
    end

    assert_response 201
  end

  test "should show cliente" do
    get cliente_url(@cliente), as: :json
    assert_response :success
  end

  test "should update cliente" do
    patch cliente_url(@cliente), params: { cliente: { apellido: @cliente.apellido, direccion: @cliente.direccion, documento_de_identidad_id: @cliente.documento_de_identidad_id, imagen_id: @cliente.imagen_id, nombre: @cliente.nombre, sexo: @cliente.sexo, telefono: @cliente.telefono } }, as: :json
    assert_response 200
  end

  test "should destroy cliente" do
    assert_difference('Cliente.count', -1) do
      delete cliente_url(@cliente), as: :json
    end

    assert_response 204
  end
end
