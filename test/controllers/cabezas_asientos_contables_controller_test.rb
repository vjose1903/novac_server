require "test_helper"

class CabezasAsientosContablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cabeza_asiento_contable = cabezas_asientos_contables(:one)
  end

  test "should get index" do
    get cabezas_asientos_contables_url, as: :json
    assert_response :success
  end

  test "should create cabeza_asiento_contable" do
    assert_difference("CabezaAsientoContable.count") do
      post cabezas_asientos_contables_url, params: { cabeza_asiento_contable: { comentario: @cabeza_asiento_contable.comentario, estado: @cabeza_asiento_contable.estado, fecha_anulacion: @cabeza_asiento_contable.fecha_anulacion, fecha_equivalente: @cabeza_asiento_contable.fecha_equivalente, periodo_fiscal_id: @cabeza_asiento_contable.periodo_fiscal_id, tipo: @cabeza_asiento_contable.tipo, usuario_anulador_id: @cabeza_asiento_contable.usuario_anulador_id, usuario_creador_id: @cabeza_asiento_contable.usuario_creador_id } }, as: :json
    end

    assert_response :created
  end

  test "should show cabeza_asiento_contable" do
    get cabeza_asiento_contable_url(@cabeza_asiento_contable), as: :json
    assert_response :success
  end

  test "should update cabeza_asiento_contable" do
    patch cabeza_asiento_contable_url(@cabeza_asiento_contable), params: { cabeza_asiento_contable: { comentario: @cabeza_asiento_contable.comentario, estado: @cabeza_asiento_contable.estado, fecha_anulacion: @cabeza_asiento_contable.fecha_anulacion, fecha_equivalente: @cabeza_asiento_contable.fecha_equivalente, periodo_fiscal_id: @cabeza_asiento_contable.periodo_fiscal_id, tipo: @cabeza_asiento_contable.tipo, usuario_anulador_id: @cabeza_asiento_contable.usuario_anulador_id, usuario_creador_id: @cabeza_asiento_contable.usuario_creador_id } }, as: :json
    assert_response :success
  end

  test "should destroy cabeza_asiento_contable" do
    assert_difference("CabezaAsientoContable.count", -1) do
      delete cabeza_asiento_contable_url(@cabeza_asiento_contable), as: :json
    end

    assert_response :no_content
  end
end
