require "test_helper"

class GruposDeCuentasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grupo_cuenta = grupos_de_cuentas(:one)
  end

  test "should get index" do
    get grupos_de_cuentas_url, as: :json
    assert_response :success
  end

  test "should create grupo_cuenta" do
    assert_difference("GrupoCuenta.count") do
      post grupos_de_cuentas_url, params: { grupo_cuenta: { descripcion: @grupo_cuenta.descripcion, grupo: @grupo_cuenta.grupo, origen: @grupo_cuenta.origen, tipo: @grupo_cuenta.tipo } }, as: :json
    end

    assert_response :created
  end

  test "should show grupo_cuenta" do
    get grupo_cuenta_url(@grupo_cuenta), as: :json
    assert_response :success
  end

  test "should update grupo_cuenta" do
    patch grupo_cuenta_url(@grupo_cuenta), params: { grupo_cuenta: { descripcion: @grupo_cuenta.descripcion, grupo: @grupo_cuenta.grupo, origen: @grupo_cuenta.origen, tipo: @grupo_cuenta.tipo } }, as: :json
    assert_response :success
  end

  test "should destroy grupo_cuenta" do
    assert_difference("GrupoCuenta.count", -1) do
      delete grupo_cuenta_url(@grupo_cuenta), as: :json
    end

    assert_response :no_content
  end
end
