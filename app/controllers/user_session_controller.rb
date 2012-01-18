class UserSessionController < ApplicationController
  def create
    omniauth = request.env['omniauth.auth']
    logger.debug "+++ #{omniauth}"

    user = User.find_by_uid(omniauth['uid'])
    if user.nil?
      user = User.create!(:uid => omniauth['uid'], 
                          :first_name => omniauth['info']['first_name'],
                          :last_name => omniauth['info']['last_name'],
                          :email => omniauth['info']['email'])
    else
      user.update_attributes!(omniauth['info'])
    end
    #session[:user_id] = omniauth
    session[:user_uid] = user.uid

    flash[:notice] = 'Successfully logged in'
    redirect_to root_path
  end

  def failure
    flash[:notice] = params[:message]
  end

  def destroy
    session[:user_uid] = nil
    flash[:notice] = 'You have successfully signed out!'
    redirect_to "#{CUSTOM_PROVIDER_URL}/users/sign_out"
  end

end
