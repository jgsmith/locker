class GroupsController < ApplicationController
  before_filter :find_group, :only => [ :show, :edit, :update ]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { render :json => { :success => false }, :status => :not_found }
      format.ext_json { render :json => { :success => false }, :status => :not_found }
    end
  end

  def index
    # show your groups and let you manage memberships
    @groups = @user.groups
    @memberships = @user.group_memberships.collect { |m| m.group }

    respond_to do |format|
      format.ext_json {
        data = {
          :items => (@groups+@memberships).uniq.collect {|g|
            { :id => g.id,
              :name => g.name,
#              :created_at => g.created_at.strftime('%Y-%m-%d %H:%M'),
              :owner => g.user.login,
              :members_can_contribute => (g.members_can_contribute? || g.user == @user),
              :type => 'Group'
            }
          }
        }
        data[:results] = data[:items].length
        render :json => data
      }
      format.html
    end
  end

  def show
  end

  def edit
  end

  def update
    members = params[:group].delete(:members)
    members = members.split(/\s+/).collect { |m|
      m.downcase!
      u = User.find_by_login(m) || User.create({:login => m, :email => m + '@tamu.edu'})
      u
    }

    @group.update_attributes(params[:group])
    if @group.errors.empty? 
      @group.group_memberships.each do |m|
        if !members.include?(m.user)
          logger.info("#{m.user.login} is not a member of the group")
          @group.group_memberships.delete(m)
        end
      end
      already_members = @group.group_memberships.collect{|m| m.user }
      (members - already_members).each do |u|
        logger.info("Adding #{u.login} as a member of the group")
        @group.group_memberships.create({ :user => u })
      end
      flash[:success] = "Group successfully updated."
    else
      flash[:errors] = @group.errors
    end
    logger.info("redirecting to: #{edit_group_url(@group)}")
    redirect_to edit_group_url(@group)
  end

  def new
  end

  def create
    members = params[:group].delete(:members)
    @group = Group.create(params[:group])
    @group.update_attribute(:user_id, @user.id)

    members.split(/\s+/).each do |m|
      # find each person or create if we can't
      m.downcase!
      u = User.find_by_login(m)
      unless u
        u = User.create({:login => m, :email => m + '@tamu.edu'})
      end

      if u
        gm = GroupMembership.create({
          :group => @group,
          :user => u
        })
      end
    end
      
    flash[:errors] = @group.errors
    if(!@group.errors.empty?)
      render :action => :new
    else
      flash[:success] = [ "Group created successfully." ]
      redirect_to :action => :edit, :id => @group
    end
  end

protected

  def find_group
    @group = Group.find(params[:id])
  end
end
