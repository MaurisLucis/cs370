class TutorsController < ApplicationController
  before_action :set_tutor, only: [:show, :edit, :update, :destroy]

  # GET /tutors
  # GET /tutors.json
  def index
    @tutors = Tutor.all
    @all_classes = BerkeleyClass.first.all_classes #whats up with 'first'?
  end

  # GET /tutors/1
  # GET /tutors/1.json
  def show
    set_tutor()
    @classes = BerkeleyClass.first.true_classes
  end

  # GET /tutors/new
  def new
    @tutor = Tutor.new
  end

  # GET /tutors/1/edit
  def edit
    @tutor = Tutor.find(params[:id])
    @classes = BerkeleyClass.first.true_classes
    @all_classes = BerkeleyClass.first.all_classes #whats up with 'first'?
    logger.debug "in here first"
  end

  # POST /tutors
  # POST /tutors.json
  def create
    @tutor = Tutor.new(tutor_params)

    respond_to do |format|
      if @tutor.save
        format.html { redirect_to @tutor, notice: 'Tutor was successfully created.' }
        format.json { render :show, status: :created, location: @tutor }
      else
        format.html { render :new }
        format.json { render json: @tutor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tutors/1
  # PATCH/PUT /tutors/1.json
  def update
    respond_to do |format|
      if @tutor.update(tutor_params) && BerkeleyClass.first.update(classes_params)
        format.html { redirect_to @tutor, notice: 'Tutor was successfully updated.' }
        format.json { render :show, status: :ok, location: @tutor }
      else
        format.html { render :edit }
        format.json { render json: @tutor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tutors/1
  # DELETE /tutors/1.json
  def destroy
    @tutor.destroy
    respond_to do |format|
      format.html { redirect_to tutors_url, notice: 'Tutor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tutor
      @tutor = Tutor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tutor_params
      params.require(:tutor).permit(:email, :grade_level)
    end

    def classes_params
      all_classes = BerkeleyClass.first.all_classes
      all_classes.each do |current_class|
        if params[:classes].key? current_class
          params[:classes][current_class] = params[:classes][current_class] == "true"
        else
          params[:classes][current_class] = false 
        end
      end
     params.require(:classes).permit(:CS61A, :CS61B, :CS61C, :CS70, :EE16A, :CS88, :CS10, :DATA8)
    end
end
