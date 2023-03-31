require "test_helper"

class EntidadCuentasContablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @entidad_cuenta_contable = entidad_cuentas_contables(:one)
  end

  test "should get index" do
    get entidad_cuentas_contables_url, as: :json
    assert_response :success
  end

  test "should create entidad_cuenta_contable" do
    assert_difference("EntidadCuentaContable.count") do
      post entidad_cuentas_contables_url, params: { entidad_cuenta_contable: { cuenta_contable_id: @entidad_cuenta_contable.cuenta_contable_id, key: @entidad_cuenta_contable.key, origen_categoria_id: @entidad_cuenta_contable.origen_categoria_id, origen_categoria_type: @entidad_cuenta_contable.origen_categoria_type, origen_entidad_id: @entidad_cuenta_contable.origen_entidad_id, origen_entidad_type: @entidad_cuenta_contable.origen_entidad_type, tipo_agrupacion_contable: @entidad_cuenta_contable.tipo_agrupacion_contable } }, as: :json
    end

    assert_response :created
  end

  test "should show entidad_cuenta_contable" do
    get entidad_cuenta_contable_url(@entidad_cuenta_contable), as: :json
    assert_response :success
  end

  test "should update entidad_cuenta_contable" do
    patch entidad_cuenta_contable_url(@entidad_cuenta_contable), params: { entidad_cuenta_contable: { cuenta_contable_id: @entidad_cuenta_contable.cuenta_contable_id, key: @entidad_cuenta_contable.key, origen_categoria_id: @entidad_cuenta_contable.origen_categoria_id, origen_categoria_type: @entidad_cuenta_contable.origen_categoria_type, origen_entidad_id: @entidad_cuenta_contable.origen_entidad_id, origen_entidad_type: @entidad_cuenta_contable.origen_entidad_type, tipo_agrupacion_contable: @entidad_cuenta_contable.tipo_agrupacion_contable } }, as: :json
    assert_response :success
  end

  test "should destroy entidad_cuenta_contable" do
    assert_difference("EntidadCuentaContable.count", -1) do
      delete entidad_cuenta_contable_url(@entidad_cuenta_contable), as: :json
    end

    assert_response :no_content
  end
end
