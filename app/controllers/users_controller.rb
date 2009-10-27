class UsersController < ApplicationController

  def edit
  end

  def update
    @user.update_attributes(params[:user])
    flash[:errors] = @user.errors
    if @user.errors.empty?
      flash[:success] = [ 'Profile changes saved.' ]
    end
    redirect_to :action => :edit
  end
end
