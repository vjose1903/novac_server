require "test_helper"

class CategoriasEntidadesContablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @categoria_entidad_contable = categorias_entidades_contables(:one)
  end

  test "should get index" do
    get categorias_entidades_contables_url, as: :json
    assert_response :success
  end

  test "should create categoria_entidad_contable" do
    assert_difference("CategoriaEntidadContable.count") do
      post categorias_entidades_contables_url, params: { categoria_entidad_contable: { cuenta_contable_auxiliar_id: @categoria_entidad_contable.cuenta_contable_auxiliar_id, cuenta_contable_control_id: @categoria_entidad_contable.cuenta_contable_control_id, descripcion: @categoria_entidad_contable.descripcion, entidad: @categoria_entidad_contable.entidad } }, as: :json
    end

    assert_response :created
  end

  test "should show categoria_entidad_contable" do
    get categoria_entidad_contable_url(@categoria_entidad_contable), as: :json
    assert_response :success
  end

  test "should update categoria_entidad_contable" do
    patch categoria_entidad_contable_url(@categoria_entidad_contable), params: { categoria_entidad_contable: { cuenta_contable_auxiliar_id: @categoria_entidad_contable.cuenta_contable_auxiliar_id, cuenta_contable_control_id: @categoria_entidad_contable.cuenta_contable_control_id, descripcion: @categoria_entidad_contable.descripcion, entidad: @categoria_entidad_contable.entidad } }, as: :json
    assert_response :success
  end

  test "should destroy categoria_entidad_contable" do
    assert_difference("CategoriaEntidadContable.count", -1) do
      delete categoria_entidad_contable_url(@categoria_entidad_contable), as: :json
    end

    assert_response :no_content
  end
end
