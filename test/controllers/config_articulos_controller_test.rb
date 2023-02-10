require "test_helper"

class ConfigArticulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @config_articulo = config_articulos(:one)
  end

  test "should get index" do
    get config_articulos_url, as: :json
    assert_response :success
  end

  test "should create config_articulo" do
    assert_difference("ConfigArticulo.count") do
      post config_articulos_url, params: { config_articulo: { porciento_ganancia: @config_articulo.porciento_ganancia } }, as: :json
    end

    assert_response :created
  end

  test "should show config_articulo" do
    get config_articulo_url(@config_articulo), as: :json
    assert_response :success
  end

  test "should update config_articulo" do
    patch config_articulo_url(@config_articulo), params: { config_articulo: { porciento_ganancia: @config_articulo.porciento_ganancia } }, as: :json
    assert_response :success
  end

  test "should destroy config_articulo" do
    assert_difference("ConfigArticulo.count", -1) do
      delete config_articulo_url(@config_articulo), as: :json
    end

    assert_response :no_content
  end
end
