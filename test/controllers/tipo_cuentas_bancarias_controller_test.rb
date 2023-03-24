require "test_helper"

class TipoCuentasBancariasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tipo_cuenta_bancaria = tipo_cuentas_bancarias(:one)
  end

  test "should get index" do
    get tipo_cuentas_bancarias_url, as: :json
    assert_response :success
  end

  test "should create tipo_cuenta_bancaria" do
    assert_difference("TipoCuentaBancaria.count") do
      post tipo_cuentas_bancarias_url, params: { tipo_cuenta_bancaria: { descripcion: @tipo_cuenta_bancaria.descripcion, estado: @tipo_cuenta_bancaria.estado } }, as: :json
    end

    assert_response :created
  end

  test "should show tipo_cuenta_bancaria" do
    get tipo_cuenta_bancaria_url(@tipo_cuenta_bancaria), as: :json
    assert_response :success
  end

  test "should update tipo_cuenta_bancaria" do
    patch tipo_cuenta_bancaria_url(@tipo_cuenta_bancaria), params: { tipo_cuenta_bancaria: { descripcion: @tipo_cuenta_bancaria.descripcion, estado: @tipo_cuenta_bancaria.estado } }, as: :json
    assert_response :success
  end

  test "should destroy tipo_cuenta_bancaria" do
    assert_difference("TipoCuentaBancaria.count", -1) do
      delete tipo_cuenta_bancaria_url(@tipo_cuenta_bancaria), as: :json
    end

    assert_response :no_content
  end
end
