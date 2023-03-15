require "test_helper"

class ConfiguracionesEntidadesCuentasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @configuracion_entidad_cuenta = configuraciones_entidades_cuentas(:one)
  end

  test "should get index" do
    get configuraciones_entidades_cuentas_url, as: :json
    assert_response :success
  end

  test "should create configuracion_entidad_cuenta" do
    assert_difference("ConfiguracionEntidadCuenta.count") do
      post configuraciones_entidades_cuentas_url, params: { configuracion_entidad_cuenta: { cuenta_contable_id: @configuracion_entidad_cuenta.cuenta_contable_id, descripcion: @configuracion_entidad_cuenta.descripcion } }, as: :json
    end

    assert_response :created
  end

  test "should show configuracion_entidad_cuenta" do
    get configuracion_entidad_cuenta_url(@configuracion_entidad_cuenta), as: :json
    assert_response :success
  end

  test "should update configuracion_entidad_cuenta" do
    patch configuracion_entidad_cuenta_url(@configuracion_entidad_cuenta), params: { configuracion_entidad_cuenta: { cuenta_contable_id: @configuracion_entidad_cuenta.cuenta_contable_id, descripcion: @configuracion_entidad_cuenta.descripcion } }, as: :json
    assert_response :success
  end

  test "should destroy configuracion_entidad_cuenta" do
    assert_difference("ConfiguracionEntidadCuenta.count", -1) do
      delete configuracion_entidad_cuenta_url(@configuracion_entidad_cuenta), as: :json
    end

    assert_response :no_content
  end
end
