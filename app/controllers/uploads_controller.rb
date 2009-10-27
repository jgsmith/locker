gem 'bluecloth', '>= 2.0.0'

class UploadsController < ApplicationController
  before_filter :find_upload, :only => [ :show ]

#  rescue_from ActiveRecord::RecordNotFound do |exception|
#    respond_to do |format|
#      format.json { render :json => { :success => false }, :status => :not_found }
#      format.ext_json { render :json => { :success => false }, :status => :not_found }
#    end
#  end

  def index
    if !@user
      render :text => 'Forbidden!', :status => :forbidden
    end

    # produce the faceted browser stuff
    respond_to do |format|
      format.html
      format.ext_json {
        data = {
          :items => @user.available_files.uniq.collect {|file|
            { :id => file.id,
              :name => file.display_name,
              :url => file.url,
              :size => file.size,
              :label => file.display_name + ' (' + file.id.to_s + ')',
              :tag => file.tags.collect { |t| t.name },
              :group => file.groups.select{|g| g.user == @user || g.is_member?(@user)}.collect {|g| g.name_for(@user) },
              :created_at => file.created_at.strftime('%Y-%m-%d %H:%M'),
              :uploaded_by => file.user.login,
              :description => (BlueCloth.new(file.description || '').to_html),
              :type => 'File'
            }
          }
        }
        data[:results] = data[:items].length
        render :json => data
      }
        
      format.json {
        data = {
          :items => @user.available_files.uniq.collect {|file|
            { :id => file.id,
              :name => file.display_name,
              :url => file.url,
              :size => file.size,
              :label => file.display_name + ' (' + file.id.to_s + ')',
              :tag => file.tags.collect { |t| t.name },
              :group => file.groups.select{|g| g.user == @user || g.is_member?(@user)}.collect {|g| g.name_for(@user) },
              :created_at => file.created_at,
              :uploaded_by => file.user.login,
              :description => (BlueCloth.new(file.description || '').to_html rescue ''),
              :type => 'File'
            }
          },
          :properties => {
            :size => {
              :valueType => 'number'
            }
          },
          :types => {
            :File => {
              :pluralLabel => 'Files'
            }
          }
        }
        render :json => data
      }
    end
  end

  def show
    if !@user
      render :text => 'Forbidden!', :status => :forbidden
    end

    if @file.can_user_view_upload?(@user)
      # take advantage of lighttpd's forwarding mechanism if we can
      send_file @file.path, 
        :type => @file.content_type,
        :filename => @file.filename
    else
      render :text => 'Forbidden.', :status => :forbidden
    end
  end

  def create
    if !@user
      render :text => 'Forbidden!', :status => :forbidden
    end

    @group = Group.find(params[:file][:group_id]) rescue nil
    if !@group.nil? && !@group.members_can_contribute?
      @group = nil
    end

    tags = [ ]
    tags = params[:file][:tags].gsub(/[^- ,A-Za-z0-9_]/,' ').gsub(/\s+/,' ').split(/\s*,\s*/) unless params[:file][:tags].empty?

    @file = Upload.create(
      :user => @user,
      :display_name => params[:file][:display_name],
      :file => params[:file][:file],
      :description => params[:file][:description]
    )

    @file.groups << @group unless @group.nil?

    tags.each do |tag|
      tag.downcase!
      t = Tag.first(:conditions => [ 'name = ?', tag ])
      if t.nil?
        t = Tag.create( :name => tag )
      end
      @file.tags << t
    end

    @file.save
    respond_to do |format|
      format.ext_json_html { render :json => ERB::Util::html_escape({ :success => true }.to_json) }
    end
  end

protected

  def find_upload
    @file = Upload.find(params[:id])
  end
end
