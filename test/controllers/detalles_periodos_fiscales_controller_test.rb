require "test_helper"

class DetallesPeriodosFiscalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @detalle_periodo_fiscal = detalles_periodos_fiscales(:one)
  end

  test "should get index" do
    get detalles_periodos_fiscales_url, as: :json
    assert_response :success
  end

  test "should create detalle_periodo_fiscal" do
    assert_difference("DetallePeriodoFiscal.count") do
      post detalles_periodos_fiscales_url, params: { detalle_periodo_fiscal: { abril: @detalle_periodo_fiscal.abril, agosto: @detalle_periodo_fiscal.agosto, diciembre: @detalle_periodo_fiscal.diciembre, enero: @detalle_periodo_fiscal.enero, febrero: @detalle_periodo_fiscal.febrero, julio: @detalle_periodo_fiscal.julio, junio: @detalle_periodo_fiscal.junio, marzo: @detalle_periodo_fiscal.marzo, mayo: @detalle_periodo_fiscal.mayo, noviembre: @detalle_periodo_fiscal.noviembre, octubre: @detalle_periodo_fiscal.octubre, periodo_fiscal_id: @detalle_periodo_fiscal.periodo_fiscal_id, septiembre: @detalle_periodo_fiscal.septiembre } }, as: :json
    end

    assert_response :created
  end

  test "should show detalle_periodo_fiscal" do
    get detalle_periodo_fiscal_url(@detalle_periodo_fiscal), as: :json
    assert_response :success
  end

  test "should update detalle_periodo_fiscal" do
    patch detalle_periodo_fiscal_url(@detalle_periodo_fiscal), params: { detalle_periodo_fiscal: { abril: @detalle_periodo_fiscal.abril, agosto: @detalle_periodo_fiscal.agosto, diciembre: @detalle_periodo_fiscal.diciembre, enero: @detalle_periodo_fiscal.enero, febrero: @detalle_periodo_fiscal.febrero, julio: @detalle_periodo_fiscal.julio, junio: @detalle_periodo_fiscal.junio, marzo: @detalle_periodo_fiscal.marzo, mayo: @detalle_periodo_fiscal.mayo, noviembre: @detalle_periodo_fiscal.noviembre, octubre: @detalle_periodo_fiscal.octubre, periodo_fiscal_id: @detalle_periodo_fiscal.periodo_fiscal_id, septiembre: @detalle_periodo_fiscal.septiembre } }, as: :json
    assert_response :success
  end

  test "should destroy detalle_periodo_fiscal" do
    assert_difference("DetallePeriodoFiscal.count", -1) do
      delete detalle_periodo_fiscal_url(@detalle_periodo_fiscal), as: :json
    end

    assert_response :no_content
  end
end
