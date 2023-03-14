require "test_helper"

class CierreCuentasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cierre_cuenta = cierre_cuentas(:one)
  end

  test "should get index" do
    get cierre_cuentas_url, as: :json
    assert_response :success
  end

  test "should create cierre_cuenta" do
    assert_difference("CierreCuenta.count") do
      post cierre_cuentas_url, params: { cierre_cuenta: { abril: @cierre_cuenta.abril, abril_credito: @cierre_cuenta.abril_credito, abril_debito: @cierre_cuenta.abril_debito, agosto: @cierre_cuenta.agosto, agosto_credito: @cierre_cuenta.agosto_credito, agosto_debito: @cierre_cuenta.agosto_debito, cuenta_contable_id: @cierre_cuenta.cuenta_contable_id, diciembre: @cierre_cuenta.diciembre, diciembre_credito: @cierre_cuenta.diciembre_credito, diciembre_debito: @cierre_cuenta.diciembre_debito, enero: @cierre_cuenta.enero, enero_credito: @cierre_cuenta.enero_credito, enero_debito: @cierre_cuenta.enero_debito, febrero: @cierre_cuenta.febrero, febrero_credito: @cierre_cuenta.febrero_credito, febrero_debito: @cierre_cuenta.febrero_debito, julio: @cierre_cuenta.julio, julio_credito: @cierre_cuenta.julio_credito, julio_debito: @cierre_cuenta.julio_debito, junio: @cierre_cuenta.junio, junio_credito: @cierre_cuenta.junio_credito, junio_debito: @cierre_cuenta.junio_debito, marzo: @cierre_cuenta.marzo, marzo_credito: @cierre_cuenta.marzo_credito, marzo_debito: @cierre_cuenta.marzo_debito, mayo: @cierre_cuenta.mayo, mayo_credito: @cierre_cuenta.mayo_credito, mayo_debito: @cierre_cuenta.mayo_debito, noviembre: @cierre_cuenta.noviembre, noviembre_credito: @cierre_cuenta.noviembre_credito, noviembre_debito: @cierre_cuenta.noviembre_debito, octubre: @cierre_cuenta.octubre, octubre_credito: @cierre_cuenta.octubre_credito, octubre_debito: @cierre_cuenta.octubre_debito, periodo_fiscal_id: @cierre_cuenta.periodo_fiscal_id, septiembre: @cierre_cuenta.septiembre, septiembre_credito: @cierre_cuenta.septiembre_credito, septiembre_debito: @cierre_cuenta.septiembre_debito, total_anual: @cierre_cuenta.total_anual } }, as: :json
    end

    assert_response :created
  end

  test "should show cierre_cuenta" do
    get cierre_cuenta_url(@cierre_cuenta), as: :json
    assert_response :success
  end

  test "should update cierre_cuenta" do
    patch cierre_cuenta_url(@cierre_cuenta), params: { cierre_cuenta: { abril: @cierre_cuenta.abril, abril_credito: @cierre_cuenta.abril_credito, abril_debito: @cierre_cuenta.abril_debito, agosto: @cierre_cuenta.agosto, agosto_credito: @cierre_cuenta.agosto_credito, agosto_debito: @cierre_cuenta.agosto_debito, cuenta_contable_id: @cierre_cuenta.cuenta_contable_id, diciembre: @cierre_cuenta.diciembre, diciembre_credito: @cierre_cuenta.diciembre_credito, diciembre_debito: @cierre_cuenta.diciembre_debito, enero: @cierre_cuenta.enero, enero_credito: @cierre_cuenta.enero_credito, enero_debito: @cierre_cuenta.enero_debito, febrero: @cierre_cuenta.febrero, febrero_credito: @cierre_cuenta.febrero_credito, febrero_debito: @cierre_cuenta.febrero_debito, julio: @cierre_cuenta.julio, julio_credito: @cierre_cuenta.julio_credito, julio_debito: @cierre_cuenta.julio_debito, junio: @cierre_cuenta.junio, junio_credito: @cierre_cuenta.junio_credito, junio_debito: @cierre_cuenta.junio_debito, marzo: @cierre_cuenta.marzo, marzo_credito: @cierre_cuenta.marzo_credito, marzo_debito: @cierre_cuenta.marzo_debito, mayo: @cierre_cuenta.mayo, mayo_credito: @cierre_cuenta.mayo_credito, mayo_debito: @cierre_cuenta.mayo_debito, noviembre: @cierre_cuenta.noviembre, noviembre_credito: @cierre_cuenta.noviembre_credito, noviembre_debito: @cierre_cuenta.noviembre_debito, octubre: @cierre_cuenta.octubre, octubre_credito: @cierre_cuenta.octubre_credito, octubre_debito: @cierre_cuenta.octubre_debito, periodo_fiscal_id: @cierre_cuenta.periodo_fiscal_id, septiembre: @cierre_cuenta.septiembre, septiembre_credito: @cierre_cuenta.septiembre_credito, septiembre_debito: @cierre_cuenta.septiembre_debito, total_anual: @cierre_cuenta.total_anual } }, as: :json
    assert_response :success
  end

  test "should destroy cierre_cuenta" do
    assert_difference("CierreCuenta.count", -1) do
      delete cierre_cuenta_url(@cierre_cuenta), as: :json
    end

    assert_response :no_content
  end
end
