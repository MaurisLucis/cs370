class AdminsController < ApplicationController
  layout 'admin_layout', :only => [:home, :update_semester, :updateCurrentSemester, :rating_tutors]
  before_action :set_admin, except: [:landing, :destroyAdminSession]
  before_action :check_logged_in, except: [:landing, :createAdminSession, :destroyAdminSession]
  # GET /admins
  # GET /admins.json
  def landing

  end

  def createAdminSession
    @admin = Admin.find(Admin.master_admin_index)
    if @admin and @admin.authenticate(params[:password])
      session[:admin_logged_in] = true
      redirect_to admin_home_path
    else
      redirect_to admin_landing_path
    end
  end

  def destroyAdminSession
    session[:admin_logged_in] = false
    redirect_to admin_landing_path
  end

  def home
    @semester_options = Admin.semester_possibilities
    @current_semester = Admin.current_semester_formatted
    @statistics_semester = Admin.statistics_semester_formatted
  end

  def update_semester
    @semester_options = Admin.semester_possibilities
    @current_semester = Admin.current_semester_formatted
    # @statistics_semester = Admin.statistics_semester_formatted ==> this will be put into stats/ratings tab
  end

  def updateCurrentSemester
    if not params[:update_current_semester].nil?
      c_sem, c_year = updateSemesterHelper(:update_current_semester)
    end
    if not c_sem.nil? and not c_year.nil? and Admin.validate_year(c_year)
      @admin.update(:current_semester => c_sem + c_year)
    else
      flash[:curr_message] = "Error updating current semester, year is likely mistyped"
    end
    redirect_to admin_update_semester_path
  end

  def rating_tutors
    @current_semester = Admin.current_semester_formatted
    @meetings = Meeting.all
    @ratings = calculate_ratings
  end

  def calculate_ratings
    @tutor_ratings = Array.new
    @meetings.each do |meet|
      tutorId = meet.tutor_id
      fn = Tutor.find_by_id(tutorId).first_name
      ln = Tutor.find_by_id(tutorId).last_name
      knowledgeable_sc = Evaluation.find_by_id(meet.evaluation_id).knowledgeable
      helpful_sc = Evaluation.find_by_id(meet.evaluation_id).helpful
      clarity_sc = Evaluation.find_by_id(meet.evaluation_id).clarity
      composite_sc = (knowledgeable_sc + helpful_sc + clarity_sc) / 3.0

      check_existing_tutor_helper(@tutor_ratings, tutorId, fn, ln, knowledgeable_sc, helpful_sc, clarity_sc, composite_sc)
    end
    @tutor_ratings
  end

  def check_existing_tutor_helper(tutor_rating_list, tutor_id, first, last, knowledge, help, clear, compo)
    found = false
    tutor_rating_list.each do |rate|
      if rate.include?(tutor_id)
        found = true
        rate[:knowledgeable] = (rate[:knowledgeable] + knowledge) / 2.0
        rate[:helpful] = (rate[:helpful] + help) / 2.0
        rate[:clarity] = (rate[:clarity] + clear) / 2.0
        rate[:composite] = (rate[:composite] + compo) / 2.0
        break
      end
    end
    if found == false
      tutor_rating_list << {tutor_id=> "#{first + " " + last}",:knowledgeable => knowledge, :helpful => help,
                            :clarity => clear, :composite => compo}
    end
    tutor_rating_list
  end

  def updateStatisticsSemester
    if not params[:update_statistics_semester].nil?
      c_sem, c_year = updateSemesterHelper(:update_statistics_semester)
    end
    if not c_sem.nil? and not c_year.nil? and Admin.validate_year(c_year)
      @admin.update(:statistics_semester => c_sem + c_year)
    else
      flash[:stat_message] = "Error updating statistics semester, year is likely mistyped"
    end
    redirect_to admin_home_path
  end

  def updateSemesterHelper val
    return params[val][:semester], params[val][:year]
  end


  private

  def check_logged_in
    if session[:admin_logged_in].nil? or not session[:admin_logged_in]
      redirect_to admin_landing_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_admin
    @admin = Admin.find(Admin.master_admin_index)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_params
    params.require(:admin).permit(:password, :password_confirmation, :statistics_semester, :current_semester)
  end
end
