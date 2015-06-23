require 'test_helper'

class TempDocumentsControllerTest < ActionController::TestCase
  setup do
    @temp_document = temp_documents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:temp_documents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create temp_document" do
    assert_difference('TempDocument.count') do
      post :create, temp_document: { document: @temp_document.document, user: @temp_document.user, xml: @temp_document.xml }
    end

    assert_redirected_to temp_document_path(assigns(:temp_document))
  end

  test "should show temp_document" do
    get :show, id: @temp_document
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @temp_document
    assert_response :success
  end

  test "should update temp_document" do
    patch :update, id: @temp_document, temp_document: { document: @temp_document.document, user: @temp_document.user, xml: @temp_document.xml }
    assert_redirected_to temp_document_path(assigns(:temp_document))
  end

  test "should destroy temp_document" do
    assert_difference('TempDocument.count', -1) do
      delete :destroy, id: @temp_document
    end

    assert_redirected_to temp_documents_path
  end
end
