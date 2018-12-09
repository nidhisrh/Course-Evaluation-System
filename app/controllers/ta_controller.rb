class TaController < ApplicationController
  before_action :check_admin_login, only: [:show]
  
  def login
    if(!params[:uin].nil?)
      if(logincheck(params[:uin],params[:password]))
        redirect_to controller: 'ta', action: 'show'
      else
        redirect_to conntroller: 'ta', action: 'login'
      end
    end
  end
 
  def logincheck(uin,password)
    #first check if input is legal
    if(uin.to_i > 999999999 || uin.to_i < 100000000)
      flash[:warning] = "Please enter a valid UIN!"
      return false
    end
    
    #then validate
    @ta = User.where(uin: uin.to_i,password: password).first
    if(@ta.nil?)
      flash[:warning] = "TA not registered or UIN and password do not match!"
      return false
    else
      if(!@ta.isapproved)
        flash[:warning] = "TA not yet approved by admin"
        return false
      else
        #set session keys
        session[:admin] = "login"
        session[:ta] = "login"
        return true
      end
    end
  end
  
  
  def showlist
    @all_ta = User.all
  end
  
  def register
  #  @all_students = Student.all
    @ta = User.new
   # @sections = Section.all.order('section_number asc')
  end
  
  def changeapprovestatus
    if(params[:id])
      @user = User.where(id: params[:id].to_i).first
      if(@user.isapproved)
        @user.isapproved = false
        approvetext = "Unapproved"
      else
        @user.isapproved = true
        approvetext = "Approved"
      end
      @user.save
      flash[:success] = "Registration Status of TA " + @user.name + " is Changed to " + approvetext
      redirect_to controller: 'ta', action: 'showlist'
    end
  end
  
  
  def questionsummary
    @all_questions = Question.order(:qid)
  end
  
  def show
    # if(session[:admin] != "login")
    #   flash.now[:danger]= "You are not logged in!"
    #   redirect_to controller: 'admin', action: 'login'
    # end
    session[:student_ids] = nil
    @all_questions = Question.order(:qid)

    @sections = Section.all.order('section_number asc')
    @list_of_sections = Section.pluck(:section_number).sort
    
    # uin = params[:uin] # retrieve student ID from URI route
    @students = Student.all.order('id asc') # look up movie by unique ID
    @average=Score.all.average(:score)
    
    @evaluations = Evaluation.all.order(:title)
    
    @evaluations.each do |evaluation|
      evaluation.avg_score = Score.avg_score(evaluation.eid)
      evaluation.max_score = Score.max_score(evaluation.eid)
      evaluation.min_score = Score.min_score(evaluation.eid)
      evaluation.student_count = Score.select(:students_id).where(eid: evaluation.eid).map(&:students_id).uniq.count
    end
    
    #control panel
    #add new section
    if(!params[:section_number].nil? and unique_section(params[:section_number]))
      if(params[:section_number] == "")
        flash[:warning] = "Section number cannot be null"
        redirect_to controller:'admin', action: 'show'
      else
        @new_section = Section.new
        @new_section.section_number = params[:section_number]
        @new_section.save
        flash[:success] = "Sections added!"
        redirect_to controller: 'ta', action: 'show'
      end
    elsif(!params[:section_number].nil? and !unique_section(params[:section_number]))
      flash[:warning] = "Section already exists"
      redirect_to controller: 'ta', action: 'show'
    end
    
    #update a student's section
    if(!params[:section].nil? and !params[:uin].nil?)
      update(params[:uin], params[:section])
    end
    
    #reset database
    if(!params[:disclaimer].nil?)
      resetStudentsDB(params[:disclaimer])
    end
  end
  
  def resetStudentsDB disclaimer
    disclaimerString = "I want to delete all students in the database, and I understand that once deleted, they are not recoverable."
    if(disclaimer == disclaimerString)
      Student.destroy_all
      flash[:success] = "Databse Reset"
      redirect_to controller: 'admin', action: 'show'
    else
      flash[:danger] = "Disclaimer does not match. Database unchanged."
      redirect_to controller: 'admin', action: 'show'
    end
  end
  
  def delete
    if(session[:admin] != "login")
      # return
      redirect_to controller: 'ta', action: 'show'
    else
      Section.where(section_number: params[:value]).first.destroy
      
      #set all students with this section number their section number to null
      @students_in_this_section = Student.where(section: params[:value])
      
      for i in 0..@students_in_this_section.size - 1
        @students_in_this_section[i].section = ""
        @students_in_this_section[i].save
      end
      flash[:success] = "section deleted!"
      redirect_to controller: 'ta', action: 'show'
    end
  end
  
  def unique_section entry
    ret = Section.where(section_number: entry)
    if !ret.empty?
      return false
    else
      return true
    end
  end
  
  def update uin,section
    @student = Student.where(uin: params[:uin].keys[0]).first
    @student.section = params[:section]
    @student.save
    flash[:success] = "Section Updated!"
    redirect_to controller: 'admin', action: 'show'
  end
  
  def logout
    session[:admin] = ""
    session[:ta] = ""
    flash[:success] = "Successfully logged out!"
    redirect_to controller: 'ta', action: 'show'
  end
  
  def logged_in?
      session[:ta] == "login"
  end
      
  def check_admin_login
    unless logged_in?
        redirect_to controller: 'ta', action: 'login'
    end
  end
  
  def export
      if(params[:display_all] == "1")
        @students = Student.all
      else
        if(params[:student_ids].nil?)
          if(session[:student_ids].nil?)
            @students = Student.all
          else
            @students = Student.where(id: session[:student_ids])
          end
        else
          @students = Student.where(id: params[:student_ids])
          session[:student_ids] = params[:student_ids]
        end  
      end
    respond_to do |format|
      format.html
      format.csv{send_data @students.to_csv,:filename => "students.csv", :disposition => 'attachment' }
    end
  end
  
  def export_questions
    @questions=Question.all
    respond_to do |format|
      format.html
      format.csv{send_data @questions.to_csv,:filename => "questions.csv", :disposition => 'attachment' }
    end
  end
end
