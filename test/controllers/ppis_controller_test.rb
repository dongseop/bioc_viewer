require 'test_helper'

class PpisControllerTest < ActionController::TestCase
  setup do
    @ppi = ppis(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ppis)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ppi" do
    assert_difference('Ppi.count') do
      post :create, ppi: { document_id: @ppi.document_id, gene1: @ppi.gene1, gene2: @ppi.gene2 }
    end

    assert_redirected_to ppi_path(assigns(:ppi))
  end

  test "should show ppi" do
    get :show, id: @ppi
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ppi
    assert_response :success
  end

  test "should update ppi" do
    patch :update, id: @ppi, ppi: { document_id: @ppi.document_id, gene1: @ppi.gene1, gene2: @ppi.gene2 }
    assert_redirected_to ppi_path(assigns(:ppi))
  end

  test "should destroy ppi" do
    assert_difference('Ppi.count', -1) do
      delete :destroy, id: @ppi
    end

    assert_redirected_to ppis_path
  end
end
