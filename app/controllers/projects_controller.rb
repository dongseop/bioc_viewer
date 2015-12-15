class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  
  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects.all

    logger.debug("ALLOWED? #{current_user.email} #{allowed_user?}")
    # unless allowed_user?
    #   render 'home/index', notice: 'BioC-Viewer is not available for service upgrade.'
    # end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    unless @project.readable?(current_user)
      redirect_to "/", error: "Cannot access the project"
    end
    @documents = @project.documents.order("id ASC").page(params[:page])
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the project"
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project.user_id = current_user.id
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the project"
    end
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    unless @project.admin?(current_user)
      redirect_to "/", error: "Cannot access the project"
    end

    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :user_id, :description, :mode)
    end
end
