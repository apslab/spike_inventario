class ApplicationController < ActionController::Base
  protect_from_forgery

  include Security

  helper_method :current_user
end
