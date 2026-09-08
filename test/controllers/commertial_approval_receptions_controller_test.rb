require "test_helper"

class CommertialApprovalReceptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @commertial_approval_reception = commertial_approval_receptions(:one)
  end

  test "should get index" do
    get commertial_approval_receptions_url, as: :json
    assert_response :success
  end

  test "should create commertial_approval_reception" do
    assert_difference("CommertialApprovalReception.count") do
      post commertial_approval_receptions_url, params: { commertial_approval_reception: { cabecera_factura_id: @commertial_approval_reception.cabecera_factura_id, detalleMotivoRechazo: @commertial_approval_reception.detalleMotivoRechazo, eNCF: @commertial_approval_reception.eNCF, estado: @commertial_approval_reception.estado, monto_total: @commertial_approval_reception.monto_total, rnc_comprador: @commertial_approval_reception.rnc_comprador, rnc_emisor: @commertial_approval_reception.rnc_emisor } }, as: :json
    end

    assert_response :created
  end

  test "should show commertial_approval_reception" do
    get commertial_approval_reception_url(@commertial_approval_reception), as: :json
    assert_response :success
  end

  test "should update commertial_approval_reception" do
    patch commertial_approval_reception_url(@commertial_approval_reception), params: { commertial_approval_reception: { cabecera_factura_id: @commertial_approval_reception.cabecera_factura_id, detalleMotivoRechazo: @commertial_approval_reception.detalleMotivoRechazo, eNCF: @commertial_approval_reception.eNCF, estado: @commertial_approval_reception.estado, monto_total: @commertial_approval_reception.monto_total, rnc_comprador: @commertial_approval_reception.rnc_comprador, rnc_emisor: @commertial_approval_reception.rnc_emisor } }, as: :json
    assert_response :success
  end

  test "should destroy commertial_approval_reception" do
    assert_difference("CommertialApprovalReception.count", -1) do
      delete commertial_approval_reception_url(@commertial_approval_reception), as: :json
    end

    assert_response :no_content
  end
end
