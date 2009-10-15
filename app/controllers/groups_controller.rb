class GroupsController < ApplicationController
  before_filter :find_group, :only => [ :show ]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { render :json => { :success => false }, :status => :not_found }
      format.ext_json { render :json => { :success => false }, :status => :not_found }
    end
  end

  def index
    # show your groups and let you manage memberships
    @groups = @user.groups
    @memberships = @user.group_memberships
  end

  def show
  end

protected

  def find_group
    @group = Group.find(params[:id])
  end
end
