require 'test_helper'

class AtypesControllerTest < ActionController::TestCase
  setup do
    @atype = atypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:atypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create atype" do
    assert_difference('Atype.count') do
      post :create, atype: { cls: @atype.cls, desc: @atype.desc, document_id: @atype.document_id, name: @atype.name, project_id: @atype.project_id }
    end

    assert_redirected_to atype_path(assigns(:atype))
  end

  test "should show atype" do
    get :show, id: @atype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @atype
    assert_response :success
  end

  test "should update atype" do
    patch :update, id: @atype, atype: { cls: @atype.cls, desc: @atype.desc, document_id: @atype.document_id, name: @atype.name, project_id: @atype.project_id }
    assert_redirected_to atype_path(assigns(:atype))
  end

  test "should destroy atype" do
    assert_difference('Atype.count', -1) do
      delete :destroy, id: @atype
    end

    assert_redirected_to atypes_path
  end
end
