require 'test_helper'

class CabeceraConducesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cabecera_conduce = cabecera_conduces(:one)
  end

  test "should get index" do
    get cabecera_conduces_url, as: :json
    assert_response :success
  end

  test "should create cabecera_conduce" do
    assert_difference('CabeceraConduce.count') do
      post cabecera_conduces_url, params: { cabecera_conduce: { cliente_id: @cabecera_conduce.cliente_id, numero_conduce: @cabecera_conduce.numero_conduce, user_id: @cabecera_conduce.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show cabecera_conduce" do
    get cabecera_conduce_url(@cabecera_conduce), as: :json
    assert_response :success
  end

  test "should update cabecera_conduce" do
    patch cabecera_conduce_url(@cabecera_conduce), params: { cabecera_conduce: { cliente_id: @cabecera_conduce.cliente_id, numero_conduce: @cabecera_conduce.numero_conduce, user_id: @cabecera_conduce.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy cabecera_conduce" do
    assert_difference('CabeceraConduce.count', -1) do
      delete cabecera_conduce_url(@cabecera_conduce), as: :json
    end

    assert_response 204
  end
end
