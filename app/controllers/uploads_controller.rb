gem 'bluecloth', '>= 2.0.0'

class UploadsController < ApplicationController
  before_filter :find_upload, :only => [ :show ]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { render :json => { :success => false }, :status => :not_found }
      format.ext_json { render :json => { :success => false }, :status => :not_found }
    end
  end

  def index
    # produce the faceted browser stuff
    respond_to do |format|
      format.html
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
    if @file.can_user_view_upload?(@user)
      # take advantage of lighttpd's forwarding mechanism if we can
      send_file @file.path, 
        :type => @file.content_type,
        :filename => @file.filename
    else
      render :text => 'Forbidden.', :status => 403
    end
  end

  def create
    @group = Group.find(params[:file][:group_id]) rescue nil
    if !@group
      @group = @user.groups.first || @user.group_memberships.first.group rescue nil
    end
    if @group
      params[:file][:group] = @group
      tags = [ ]
      tags = params[:file][:tags].gsub(/[^- ,a-z0-9_]/,' ').gsub(/\s+/,' ').split(/\s*,\s*/) unless params[:file][:tags].empty?

      @file = Upload.create(
        :user => @user,
        :display_name => params[:file][:display_name],
        :file => params[:file][:file],
        :description => params[:file][:description]
      )

      tags.each do |tag|
        t = Tag.first(:conditions => [ 'name = ?', tag ])
        if t.nil?
          t = Tag.create( :name => tag )
        end
        @file.tags << t
      end
      @file.groups << @group
      respond_to do |format|
        format.ext_json_html { render :json => ERB::Util::html_escape({ :success => true }.to_json) }
      end
    else
      respond_to do |format|
        format.ext_json_html { render :json => ERB::Util::html_escape({ :success => false }.to_json) }
      end
    end
  end

protected

  def find_upload
    @file = Upload.find(params[:id])
  end
end
