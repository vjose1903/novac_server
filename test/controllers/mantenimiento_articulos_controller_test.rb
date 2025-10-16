require 'test_helper'

class MantenimientoArticulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mantenimiento_articulo = mantenimiento_articulos(:one)
  end

  test "should get index" do
    get mantenimiento_articulos_url, as: :json
    assert_response :success
  end

  test "should create mantenimiento_articulo" do
    assert_difference('MantenimientoArticulo.count') do
      post mantenimiento_articulos_url, params: { mantenimiento_articulo: { ant: @mantenimiento_articulo.ant, ant_alertaExistencia: @mantenimiento_articulo.ant_alertaExistencia, ant_isDetallable: @mantenimiento_articulo.ant_isDetallable, ant_medida: @mantenimiento_articulo.ant_medida, ant_nombre: @mantenimiento_articulo.ant_nombre, ant_precioP: @mantenimiento_articulo.ant_precioP, ant_suplidor: @mantenimiento_articulo.ant_suplidor, ant_tipoArticulo: @mantenimiento_articulo.ant_tipoArticulo, articulo_id: @mantenimiento_articulo.articulo_id, user_id: @mantenimiento_articulo.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show mantenimiento_articulo" do
    get mantenimiento_articulo_url(@mantenimiento_articulo), as: :json
    assert_response :success
  end

  test "should update mantenimiento_articulo" do
    patch mantenimiento_articulo_url(@mantenimiento_articulo), params: { mantenimiento_articulo: { ant: @mantenimiento_articulo.ant, ant_alertaExistencia: @mantenimiento_articulo.ant_alertaExistencia, ant_isDetallable: @mantenimiento_articulo.ant_isDetallable, ant_medida: @mantenimiento_articulo.ant_medida, ant_nombre: @mantenimiento_articulo.ant_nombre, ant_precioP: @mantenimiento_articulo.ant_precioP, ant_suplidor: @mantenimiento_articulo.ant_suplidor, ant_tipoArticulo: @mantenimiento_articulo.ant_tipoArticulo, articulo_id: @mantenimiento_articulo.articulo_id, user_id: @mantenimiento_articulo.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy mantenimiento_articulo" do
    assert_difference('MantenimientoArticulo.count', -1) do
      delete mantenimiento_articulo_url(@mantenimiento_articulo), as: :json
    end

    assert_response 204
  end
end
