require "test_helper"

class TransferenciasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transferencia = transferencias(:one)
  end

  test "should get index" do
    get transferencias_url, as: :json
    assert_response :success
  end

  test "should create transferencia" do
    assert_difference("Transferencia.count") do
      post transferencias_url, params: { transferencia: { comentario: @transferencia.comentario, cuenta_bancaria_destino_id: @transferencia.cuenta_bancaria_destino_id, cuenta_bancaria_origen_id: @transferencia.cuenta_bancaria_origen_id, cuenta_bancaria_tercero: @transferencia.cuenta_bancaria_tercero, estado: @transferencia.estado, fecha_anulacion: @transferencia.fecha_anulacion, fecha_equivalente: @transferencia.fecha_equivalente, last_user_update_id: @transferencia.last_user_update_id, monto: @transferencia.monto, monto_local: @transferencia.monto_local, nombre_banco_tercero: @transferencia.nombre_banco_tercero, numero_referencia: @transferencia.numero_referencia, tasa: @transferencia.tasa, tipo: @transferencia.tipo, user_anulador_id: @transferencia.user_anulador_id, user_creador_id: @transferencia.user_creador_id } }, as: :json
    end

    assert_response :created
  end

  test "should show transferencia" do
    get transferencia_url(@transferencia), as: :json
    assert_response :success
  end

  test "should update transferencia" do
    patch transferencia_url(@transferencia), params: { transferencia: { comentario: @transferencia.comentario, cuenta_bancaria_destino_id: @transferencia.cuenta_bancaria_destino_id, cuenta_bancaria_origen_id: @transferencia.cuenta_bancaria_origen_id, cuenta_bancaria_tercero: @transferencia.cuenta_bancaria_tercero, estado: @transferencia.estado, fecha_anulacion: @transferencia.fecha_anulacion, fecha_equivalente: @transferencia.fecha_equivalente, last_user_update_id: @transferencia.last_user_update_id, monto: @transferencia.monto, monto_local: @transferencia.monto_local, nombre_banco_tercero: @transferencia.nombre_banco_tercero, numero_referencia: @transferencia.numero_referencia, tasa: @transferencia.tasa, tipo: @transferencia.tipo, user_anulador_id: @transferencia.user_anulador_id, user_creador_id: @transferencia.user_creador_id } }, as: :json
    assert_response :success
  end

  test "should destroy transferencia" do
    assert_difference("Transferencia.count", -1) do
      delete transferencia_url(@transferencia), as: :json
    end

    assert_response :no_content
  end
end
