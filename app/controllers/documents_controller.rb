class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  
  # GET /documents
  # GET /documents.json
  def index
    unless current_user.super_admin?
      redirect_to "/", error: "Cannot access the document"
    end

    @documents = Document.all
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @project = @document.project
    @document.adjust_atypes

    unless @project.readable?(current_user)
      redirect_to "/", error: "Cannot access the document"
    end
    respond_to do |format|
      format.html
      format.json
      format.xml {render xml: @document.xml}
    end
  end

  # GET /documents/new
  def new
    @project = Project.find(params[:project_id])
    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the document"
    end
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
    @project = @document.project
    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the document"
    end
  end

  # POST /documents
  # POST /documents.json
  def create
    @project = Project.find(params[:project_id])

    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the document"
    end
    @document = Document.create_from_file(params[:file])
    if @document.nil?
      respond_to do |format|
        format.html { render status: :unprocessable_entity, text: "Invalid document by BioC DTD"}
      end
      return 
    end
    @document.project_id = @project.id
    @document.user_id = current_user.id

    respond_to do |format|
      if @document.save
        format.html { redirect_to @project, notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    @project = @document.project
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @project, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @project = Project.find(params[:project_id])
    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the document"
    end

    return_url = if @project.present? then url_for(@project) else documents_url end
    @document.destroy
    respond_to do |format|
      format.html { redirect_to return_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def merge
    @project = Project.find(params[:project_id])
    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the document"
    end
   
    # logger.debug(params[:files].inspect)
    errors = []
    @document = Document.merge_documents(@project, current_user, params[:files], errors)
    if @document.nil?
      respond_to do |format|
        format.html { redirect_to @project, error: errors.join(",")}
      end
      return 
    end

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: 'Merged document was successfully created.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:file, :doc_id, :d_date, :key, :source, :filename)
    end
end
