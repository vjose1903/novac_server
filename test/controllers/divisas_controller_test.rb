require "test_helper"

class DivisasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @divisa = divisas(:one)
  end

  test "should get index" do
    get divisas_url, as: :json
    assert_response :success
  end

  test "should create divisa" do
    assert_difference("Divisa.count") do
      post divisas_url, params: { divisa: { estado: @divisa.estado, imagen: @divisa.imagen, is_principal: @divisa.is_principal, nombre: @divisa.nombre, simbolo: @divisa.simbolo } }, as: :json
    end

    assert_response :created
  end

  test "should show divisa" do
    get divisa_url(@divisa), as: :json
    assert_response :success
  end

  test "should update divisa" do
    patch divisa_url(@divisa), params: { divisa: { estado: @divisa.estado, imagen: @divisa.imagen, is_principal: @divisa.is_principal, nombre: @divisa.nombre, simbolo: @divisa.simbolo } }, as: :json
    assert_response :success
  end

  test "should destroy divisa" do
    assert_difference("Divisa.count", -1) do
      delete divisa_url(@divisa), as: :json
    end

    assert_response :no_content
  end
end
