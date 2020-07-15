require 'test_helper'

class DocumentosDeIdentidadControllerTest < ActionDispatch::IntegrationTest
  setup do
    @documento_de_identidad = documentos_de_identidad(:one)
  end

  test "should get index" do
    get documentos_de_identidad_url, as: :json
    assert_response :success
  end

  test "should create documento_de_identidad" do
    assert_difference('DocumentoDeIdentidad.count') do
      post documentos_de_identidad_url, params: { documento_de_identidad: { cliente_id: @documento_de_identidad.cliente_id, descripcion: @documento_de_identidad.descripcion, documento: @documento_de_identidad.documento, suplidor_id: @documento_de_identidad.suplidor_id, user_id: @documento_de_identidad.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show documento_de_identidad" do
    get documento_de_identidad_url(@documento_de_identidad), as: :json
    assert_response :success
  end

  test "should update documento_de_identidad" do
    patch documento_de_identidad_url(@documento_de_identidad), params: { documento_de_identidad: { cliente_id: @documento_de_identidad.cliente_id, descripcion: @documento_de_identidad.descripcion, documento: @documento_de_identidad.documento, suplidor_id: @documento_de_identidad.suplidor_id, user_id: @documento_de_identidad.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy documento_de_identidad" do
    assert_difference('DocumentoDeIdentidad.count', -1) do
      delete documento_de_identidad_url(@documento_de_identidad), as: :json
    end

    assert_response 204
  end
end
