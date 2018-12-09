require 'net/https'
require 'uri'

class UsersController < ApplicationController
  def create
    params.permit! #allow mass assignment
    @user = User.new(params[:user])
    @user.isapproved = false
    @user.created_at =  DateTime.now
    res = validate_entry(@user)
    #debugger
    if(res == true)
      if(@user.save)
        redirect_to controller: 'ta', action: 'register'
      end
    else
      redirect_to controller: 'ta', action: 'register'
    end
  end
  
  def validate_entry entry
    puts "validating"
    
    #nil entry
    if(entry.uin.nil? ||entry.name.nil? || entry.name == "")
      flash[:warning] = "Please fill in all required fields!!"
      return false
    end

    
    #inavlid uin
    if(entry.uin > 999999999 || entry.uin < 100000000)
      flash[:warning] = "Invalid UIN!"
      return false
    end
    
    #uin uniqueness
    ret = User.where(uin: entry.uin)
    if !ret.empty?
      flash[:warning] = "UIN already exist!"
      return false
    end
    
    flash[:success] = "TA registered!"
    return true
  end
end