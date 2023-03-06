require "test_helper"

class CuentasContablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cuenta_contable = cuentas_contables(:one)
  end

  test "should get index" do
    get cuentas_contables_url, as: :json
    assert_response :success
  end

  test "should create cuenta_contable" do
    assert_difference("CuentaContable.count") do
      post cuentas_contables_url, params: { cuenta_contable: { codigo: @cuenta_contable.codigo, cuenta_control: @cuenta_contable.cuenta_control, descripcion: @cuenta_contable.descripcion, grupo_cuenta_id: @cuenta_contable.grupo_cuenta_id, nivel: @cuenta_contable.nivel, origen: @cuenta_contable.origen, tipo: @cuenta_contable.tipo } }, as: :json
    end

    assert_response :created
  end

  test "should show cuenta_contable" do
    get cuenta_contable_url(@cuenta_contable), as: :json
    assert_response :success
  end

  test "should update cuenta_contable" do
    patch cuenta_contable_url(@cuenta_contable), params: { cuenta_contable: { codigo: @cuenta_contable.codigo, cuenta_control: @cuenta_contable.cuenta_control, descripcion: @cuenta_contable.descripcion, grupo_cuenta_id: @cuenta_contable.grupo_cuenta_id, nivel: @cuenta_contable.nivel, origen: @cuenta_contable.origen, tipo: @cuenta_contable.tipo } }, as: :json
    assert_response :success
  end

  test "should destroy cuenta_contable" do
    assert_difference("CuentaContable.count", -1) do
      delete cuenta_contable_url(@cuenta_contable), as: :json
    end

    assert_response :no_content
  end
end
