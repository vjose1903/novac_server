require "test_helper"

class SubTipoArticulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sub_tipo_articulo = sub_tipo_articulos(:one)
  end

  test "should get index" do
    get sub_tipo_articulos_url, as: :json
    assert_response :success
  end

  test "should create sub_tipo_articulo" do
    assert_difference("SubTipoArticulo.count") do
      post sub_tipo_articulos_url, params: { sub_tipo_articulo: { cuenta_contable_id: @sub_tipo_articulo.cuenta_contable_id, descripcion: @sub_tipo_articulo.descripcion, tipo_articulo_id: @sub_tipo_articulo.tipo_articulo_id } }, as: :json
    end

    assert_response :created
  end

  test "should show sub_tipo_articulo" do
    get sub_tipo_articulo_url(@sub_tipo_articulo), as: :json
    assert_response :success
  end

  test "should update sub_tipo_articulo" do
    patch sub_tipo_articulo_url(@sub_tipo_articulo), params: { sub_tipo_articulo: { cuenta_contable_id: @sub_tipo_articulo.cuenta_contable_id, descripcion: @sub_tipo_articulo.descripcion, tipo_articulo_id: @sub_tipo_articulo.tipo_articulo_id } }, as: :json
    assert_response :success
  end

  test "should destroy sub_tipo_articulo" do
    assert_difference("SubTipoArticulo.count", -1) do
      delete sub_tipo_articulo_url(@sub_tipo_articulo), as: :json
    end

    assert_response :no_content
  end
end
