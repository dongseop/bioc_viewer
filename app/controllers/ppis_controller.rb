class PpisController < ApplicationController
  before_action :set_ppi, only: [:show, :edit, :update, :destroy]

  # GET /ppis
  # GET /ppis.json
  def index
    @document = Document.find(params[:document_id])
    @ppis = @document.ppis
    respond_to do |format|
      format.html
      format.json
      format.csv { send_data @ppis.to_csv, :filename => "#{@document.unique_id}_ppi.csv" }
      format.xls { send_data render_to_string(:template => "ppis/index.xls.erb"),
             :filename => "#{@document.unique_id}_ppi.xls" }
    end
  end

  # GET /ppis/1
  # GET /ppis/1.json
  def show
  end

  # GET /ppis/new
  def new
    @ppi = Ppi.new
  end

  # GET /ppis/1/edit
  def edit
  end

  # POST /ppis
  # POST /ppis.json
  def create
    @ppi = Ppi.new(ppi_params)
    @document = Document.find(params[:document_id])
    dup = @document.ppis.where("(gene1 = ? and gene2 = ?) and (exp = ?) and (itype = ?)",
        params[:ppi][:gene1], params[:ppi][:gene2], 
        params[:ppi][:exp], params[:ppi][:itype]
      ).first

    unless dup.nil?
      render :nothing => true, :status => :conflict
      return
    end

    @ppi.document_id = @document.id
    respond_to do |format|
      if @ppi.save
        format.html { redirect_to @ppi, notice: 'Ppi was successfully created.' }
        format.json { render :show, status: :created, location: @ppi }
      else
        format.html { render :new }
        format.json { render json: @ppi.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ppis/1
  # PATCH/PUT /ppis/1.json
  def update
    @ppi.itype = params[:itype] if params[:itype].present?
    @ppi.exp = params[:exp] if params[:exp].present?

    dup = @ppi.document.ppis.where("(gene1 = ? and gene2 = ?) and (exp = ?) and (itype = ?)",
        @ppi.gene1, @ppi.gene2, 
        @ppi.exp, @ppi.itype 
      ).first

    if !dup.nil? && dup.id != @ppi.id
      render :nothing => true, :status => :conflict
      return
    end

    respond_to do |format|
      if @ppi.save
        format.html { redirect_to @ppi, notice: 'Ppi was successfully updated.' }
        format.json { render :show, status: :ok, location: @ppi }
      else
        format.html { render :edit }
        format.json { render json: @ppi.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ppis/1
  # DELETE /ppis/1.json
  def destroy
    @ppi.destroy
    respond_to do |format|
      format.html { redirect_to ppis_url, notice: 'Ppi was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ppi
      @ppi = Ppi.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ppi_params
      params.require(:ppi).permit(:gene1, :gene2, :name1, :name2, :itype, :exp)
    end
end
