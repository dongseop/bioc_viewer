class TempDocumentsController < ApplicationController
  before_action :set_temp_document, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  
  # GET /temp_documents
  # GET /temp_documents.json
  def index
    @temp_documents = TempDocument.all
  end

  # GET /temp_documents/1
  # GET /temp_documents/1.json
  def show
  end

  # GET /temp_documents/new
  def new
    @temp_document = TempDocument.new
  end

  # GET /temp_documents/1/edit
  def edit
  end

  # POST /temp_documents
  # POST /temp_documents.json
  def create
    @temp_document = TempDocument.new(temp_document_params)

    respond_to do |format|
      if @temp_document.save
        format.html { redirect_to @temp_document, notice: 'Temp document was successfully created.' }
        format.json { render :show, status: :created, location: @temp_document }
      else
        format.html { render :new }
        format.json { render json: @temp_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /temp_documents/1
  # PATCH/PUT /temp_documents/1.json
  def update
    respond_to do |format|
      if @temp_document.update(temp_document_params)
        format.html { redirect_to @temp_document, notice: 'Temp document was successfully updated.' }
        format.json { render :show, status: :ok, location: @temp_document }
      else
        format.html { render :edit }
        format.json { render json: @temp_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /temp_documents/1
  # DELETE /temp_documents/1.json
  def destroy
    @temp_document.destroy
    respond_to do |format|
      format.html { redirect_to temp_documents_url, notice: 'Temp document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_temp_document
      @temp_document = TempDocument.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def temp_document_params
      params.require(:temp_document).permit(:user, :document, :xml)
    end
end
