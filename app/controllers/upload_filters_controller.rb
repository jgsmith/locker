class UploadFiltersController < ApplicationController
  before_filter :find_upload_filter, :only => [ :edit, :update, :change_web_id ]
  before_filter :find_upload_filter_by_ids, :only => [ :show ]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { render :json => { :success => false }, :status => :not_found }
      format.ext_json { render :json => { :success => false }, :status => :not_found }
    end
  end

  def index
    @filters = @user.upload_filters
  end

  def show
    if @filter.user != @user
      render :text => 'Forbidden!', :status => :forbidden
    end
    @files = @filter.files
    respond_to do |format|
      format.html
      format.atom
      format.json { render :json => @files.to_json }
    end
  end

  def new
    @upload_filter = UploadFilter.new
  end

  def create
    tag_field = params[:upload_filter].delete(:tag_list)
    group_field = params[:upload_filter].delete(:groups)
    params[:upload_filter][:user_id] = @user.id
    @upload_filter = UploadFilter.create(params[:upload_filter])
    #@upload_filter.user = @user
    @upload_filter.generate_web_id
    if @upload_filter.save
      # add tags/groups
      tags = tag_field.downcase.split(/\s+/).collect{ |t|
        Tag.find_by_name(t) rescue nil
      }.uniq - [ nil ]
      groups = group_field.collect { |g|
        Group.find(g) rescue nil
      }.uniq - [ nil ]
      @upload_filter.tags = tags
      @upload_filter.groups = groups
      flash[:success] = [ 'Feed created successfully.' ]
      redirect_to :action => :edit, :id => @upload_filter
    else
      flash[:errors] = @upload_filter.errors
      render :action => :new
    end
  end

  def edit
    @upload_filter = @filter
    if @upload_filter.user != @user
      render :text => 'Forbidden!', :status => :forbidden
    end
  end

  def change_web_id
    @filter.generate_web_id
    if(@filter.save)
      flash[:success] = [ 'Feed URL updated successfully.' ]
    end
    redirect_to :action => :show, :id => @filter
  end

  def update
    @upload_filter = @filter
    if @upload_filter.user != @user
      render :text => 'Forbidden!', :status => :forbidden
    end
    tag_field = params[:upload_filter].delete(:tag_list)
    group_field = params[:upload_filter].delete(:groups)
    if @upload_filter.update_attributes(params[:upload_filter])
      tags = tag_field.downcase.split(/\s+/).collect{ |t|
        Tag.find_by_name(t) rescue nil
      }.uniq - [ nil ]
      groups = group_field.collect { |g|
        Group.find(g) rescue nil
      }.uniq - [ nil ]
      @upload_filter.tags = tags
      @upload_filter.groups = groups
      flash[:success] = [ 'Feed updated successfully.' ]
      render :action => :edit
    else
      flash[:errors] = @upload_filter.errors
      render :action => :edit
    end
  end

protected

  def find_upload_filter
    @filter = UploadFilter.find(params[:id])
  end

  def find_upload_filter_by_ids
    if params[:id] =~ /^\d+$/
      @filter = UploadFilter.find(params[:id])
    else
      @filter = UploadFilter.find_by_web_id(params[:id])
      @user = @filter.user if @filter
    end
  end
end
