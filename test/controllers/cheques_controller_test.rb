require "test_helper"

class ChequesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cheque = cheques(:one)
  end

  test "should get index" do
    get cheques_url, as: :json
    assert_response :success
  end

  test "should create cheque" do
    assert_difference("Cheque.count") do
      post cheques_url, params: { cheque: { balance: @cheque.balance, comentario: @cheque.comentario, cuenta_bancaria_id: @cheque.cuenta_bancaria_id, estado: @cheque.estado, fecha_anulacion: @cheque.fecha_anulacion, fecha_equivalente: @cheque.fecha_equivalente, fecha_update: @cheque.fecha_update, last_user_update_id: @cheque.last_user_update_id, monto: @cheque.monto, monto_local: @cheque.monto_local, secuencia: @cheque.secuencia, tasa: @cheque.tasa, user_anulador_id: @cheque.user_anulador_id, user_creador_id: @cheque.user_creador_id } }, as: :json
    end

    assert_response :created
  end

  test "should show cheque" do
    get cheque_url(@cheque), as: :json
    assert_response :success
  end

  test "should update cheque" do
    patch cheque_url(@cheque), params: { cheque: { balance: @cheque.balance, comentario: @cheque.comentario, cuenta_bancaria_id: @cheque.cuenta_bancaria_id, estado: @cheque.estado, fecha_anulacion: @cheque.fecha_anulacion, fecha_equivalente: @cheque.fecha_equivalente, fecha_update: @cheque.fecha_update, last_user_update_id: @cheque.last_user_update_id, monto: @cheque.monto, monto_local: @cheque.monto_local, secuencia: @cheque.secuencia, tasa: @cheque.tasa, user_anulador_id: @cheque.user_anulador_id, user_creador_id: @cheque.user_creador_id } }, as: :json
    assert_response :success
  end

  test "should destroy cheque" do
    assert_difference("Cheque.count", -1) do
      delete cheque_url(@cheque), as: :json
    end

    assert_response :no_content
  end
end
