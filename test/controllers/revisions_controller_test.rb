require 'test_helper'

class RevisionsControllerTest < ActionController::TestCase
  setup do
    @revision = revisions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:revisions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create revision" do
    assert_difference('Revision.count') do
      post :create, revision: { comment: @revision.comment, document_id: @revision.document_id, user_id: @revision.user_id, version: @revision.version, xml: @revision.xml }
    end

    assert_redirected_to revision_path(assigns(:revision))
  end

  test "should show revision" do
    get :show, id: @revision
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @revision
    assert_response :success
  end

  test "should update revision" do
    patch :update, id: @revision, revision: { comment: @revision.comment, document_id: @revision.document_id, user_id: @revision.user_id, version: @revision.version, xml: @revision.xml }
    assert_redirected_to revision_path(assigns(:revision))
  end

  test "should destroy revision" do
    assert_difference('Revision.count', -1) do
      delete :destroy, id: @revision
    end

    assert_redirected_to revisions_path
  end
end
