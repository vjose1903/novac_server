require "test_helper"

class EcfReceptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ecf_reception = ecf_receptions(:one)
  end

  test "should get index" do
    get ecf_receptions_url, as: :json
    assert_response :success
  end

  test "should create ecf_reception" do
    assert_difference("EcfReception.count") do
      post ecf_receptions_url, params: { ecf_reception: { eNCF: @ecf_reception.eNCF, monto_total: @ecf_reception.monto_total, rnc_comprador: @ecf_reception.rnc_comprador, rnc_emisor: @ecf_reception.rnc_emisor } }, as: :json
    end

    assert_response :created
  end

  test "should show ecf_reception" do
    get ecf_reception_url(@ecf_reception), as: :json
    assert_response :success
  end

  test "should update ecf_reception" do
    patch ecf_reception_url(@ecf_reception), params: { ecf_reception: { eNCF: @ecf_reception.eNCF, monto_total: @ecf_reception.monto_total, rnc_comprador: @ecf_reception.rnc_comprador, rnc_emisor: @ecf_reception.rnc_emisor } }, as: :json
    assert_response :success
  end

  test "should destroy ecf_reception" do
    assert_difference("EcfReception.count", -1) do
      delete ecf_reception_url(@ecf_reception), as: :json
    end

    assert_response :no_content
  end
end
