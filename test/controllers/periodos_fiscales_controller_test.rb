require "test_helper"

class PeriodosFiscalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @periodo_fiscal = periodos_fiscales(:one)
  end

  test "should get index" do
    get periodos_fiscales_url, as: :json
    assert_response :success
  end

  test "should create periodo_fiscal" do
    assert_difference("PeriodoFiscal.count") do
      post periodos_fiscales_url, params: { periodo_fiscal: { estado: @periodo_fiscal.estado, fecha_cierre: @periodo_fiscal.fecha_cierre, fecha_inicio: @periodo_fiscal.fecha_inicio } }, as: :json
    end

    assert_response :created
  end

  test "should show periodo_fiscal" do
    get periodo_fiscal_url(@periodo_fiscal), as: :json
    assert_response :success
  end

  test "should update periodo_fiscal" do
    patch periodo_fiscal_url(@periodo_fiscal), params: { periodo_fiscal: { estado: @periodo_fiscal.estado, fecha_cierre: @periodo_fiscal.fecha_cierre, fecha_inicio: @periodo_fiscal.fecha_inicio } }, as: :json
    assert_response :success
  end

  test "should destroy periodo_fiscal" do
    assert_difference("PeriodoFiscal.count", -1) do
      delete periodo_fiscal_url(@periodo_fiscal), as: :json
    end

    assert_response :no_content
  end
end
