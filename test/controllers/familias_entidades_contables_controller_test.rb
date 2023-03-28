require "test_helper"

class FamiliasEntidadesContablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @familia_entidad_contable = familias_entidades_contables(:one)
  end

  test "should get index" do
    get familias_entidades_contables_url, as: :json
    assert_response :success
  end

  test "should create familia_entidad_contable" do
    assert_difference("FamiliaEntidadContable.count") do
      post familias_entidades_contables_url, params: { familia_entidad_contable: { cuenta_contable_auxiliar_id: @familia_entidad_contable.cuenta_contable_auxiliar_id, cuenta_contable_control_id: @familia_entidad_contable.cuenta_contable_control_id, descripcion: @familia_entidad_contable.descripcion, entidad: @familia_entidad_contable.entidad } }, as: :json
    end

    assert_response :created
  end

  test "should show familia_entidad_contable" do
    get familia_entidad_contable_url(@familia_entidad_contable), as: :json
    assert_response :success
  end

  test "should update familia_entidad_contable" do
    patch familia_entidad_contable_url(@familia_entidad_contable), params: { familia_entidad_contable: { cuenta_contable_auxiliar_id: @familia_entidad_contable.cuenta_contable_auxiliar_id, cuenta_contable_control_id: @familia_entidad_contable.cuenta_contable_control_id, descripcion: @familia_entidad_contable.descripcion, entidad: @familia_entidad_contable.entidad } }, as: :json
    assert_response :success
  end

  test "should destroy familia_entidad_contable" do
    assert_difference("FamiliaEntidadContable.count", -1) do
      delete familia_entidad_contable_url(@familia_entidad_contable), as: :json
    end

    assert_response :no_content
  end
end
