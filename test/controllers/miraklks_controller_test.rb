require 'test_helper'

class MiraklksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @miraklk = miraklks(:one)
  end

  test "should get index" do
    get miraklks_url, as: :json
    assert_response :success
  end

  test "should create miraklk" do
    assert_difference('Miraklk.count') do
      post miraklks_url, params: { miraklk: { prueba: @miraklk.prueba, prueba2: @miraklk.prueba2, prueba3: @miraklk.prueba3 } }, as: :json
    end

    assert_response 201
  end

  test "should show miraklk" do
    get miraklk_url(@miraklk), as: :json
    assert_response :success
  end

  test "should update miraklk" do
    patch miraklk_url(@miraklk), params: { miraklk: { prueba: @miraklk.prueba, prueba2: @miraklk.prueba2, prueba3: @miraklk.prueba3 } }, as: :json
    assert_response 200
  end

  test "should destroy miraklk" do
    assert_difference('Miraklk.count', -1) do
      delete miraklk_url(@miraklk), as: :json
    end

    assert_response 204
  end
end
