# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExtScaffold

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :set_users

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def set_users
    @actual_user = actual_user
    @user = current_user
  end
end
