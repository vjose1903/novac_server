require 'test_helper'

class MantenimientoFormulasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mantenimiento_formula = mantenimiento_formulas(:one)
  end

  test "should get index" do
    get mantenimiento_formulas_url, as: :json
    assert_response :success
  end

  test "should create mantenimiento_formula" do
    assert_difference('MantenimientoFormula.count') do
      post mantenimiento_formulas_url, params: { mantenimiento_formula: { articulo_id: @mantenimiento_formula.articulo_id, cantidad: @mantenimiento_formula.cantidad, mantenimiento_articulos_id: @mantenimiento_formula.mantenimiento_articulos_id } }, as: :json
    end

    assert_response 201
  end

  test "should show mantenimiento_formula" do
    get mantenimiento_formula_url(@mantenimiento_formula), as: :json
    assert_response :success
  end

  test "should update mantenimiento_formula" do
    patch mantenimiento_formula_url(@mantenimiento_formula), params: { mantenimiento_formula: { articulo_id: @mantenimiento_formula.articulo_id, cantidad: @mantenimiento_formula.cantidad, mantenimiento_articulos_id: @mantenimiento_formula.mantenimiento_articulos_id } }, as: :json
    assert_response 200
  end

  test "should destroy mantenimiento_formula" do
    assert_difference('MantenimientoFormula.count', -1) do
      delete mantenimiento_formula_url(@mantenimiento_formula), as: :json
    end

    assert_response 204
  end
end
