require "test_helper"

class SecuenciaDocumentosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @secuencia_documento = secuencia_documentos(:one)
  end

  test "should get index" do
    get secuencia_documentos_url, as: :json
    assert_response :success
  end

  test "should create secuencia_documento" do
    assert_difference("SecuenciaDocumento.count") do
      post secuencia_documentos_url, params: { secuencia_documento: { origen_secuencia_id: @secuencia_documento.origen_secuencia_id, origen_secuencia_type: @secuencia_documento.origen_secuencia_type, secuencia: @secuencia_documento.secuencia } }, as: :json
    end

    assert_response :created
  end

  test "should show secuencia_documento" do
    get secuencia_documento_url(@secuencia_documento), as: :json
    assert_response :success
  end

  test "should update secuencia_documento" do
    patch secuencia_documento_url(@secuencia_documento), params: { secuencia_documento: { origen_secuencia_id: @secuencia_documento.origen_secuencia_id, origen_secuencia_type: @secuencia_documento.origen_secuencia_type, secuencia: @secuencia_documento.secuencia } }, as: :json
    assert_response :success
  end

  test "should destroy secuencia_documento" do
    assert_difference("SecuenciaDocumento.count", -1) do
      delete secuencia_documento_url(@secuencia_documento), as: :json
    end

    assert_response :no_content
  end
end
