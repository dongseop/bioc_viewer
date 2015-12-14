class AtypesController < ApplicationController
  before_action :set_atype, only: [:show, :edit, :update, :destroy]
  before_action :set_document

  # GET /atypes
  # GET /atypes.json
  def index
    @document.adjust_atypes
    @atypes = @document.atypes
  end

  # GET /atypes/1
  # GET /atypes/1.json
  def show
  end

  # GET /atypes/new
  def new
    @atype = Atype.new
  end

  # GET /atypes/1/edit
  def edit
  end

  # POST /atypes
  # POST /atypes.json
  def create
    @document.atypes.each do |atype|
      value = params["C#{atype.id}"]
      unless value.nil?
        atype.cls = value
        atype.save
      end
    end
    redirect_to @document, notice: 'Settings were successfully updated.'
  end

  # PATCH/PUT /atypes/1
  # PATCH/PUT /atypes/1.json
  def update
    respond_to do |format|
      if @atype.update(atype_params)
        format.html { redirect_to @atype, notice: 'Atype was successfully updated.' }
        format.json { render :show, status: :ok, location: @atype }
      else
        format.html { render :edit }
        format.json { render json: @atype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /atypes/1
  # DELETE /atypes/1.json
  def destroy
    @atype.destroy
    respond_to do |format|
      format.html { redirect_to atypes_url, notice: 'Atype was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_atype
      @atype = Atype.find(params[:id])
    end
    def set_document
      @document = Document.find(params[:document_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def atype_params
      params.require(:atype).permit(:name, :cls, :desc, :document_id, :project_id)
    end
end
