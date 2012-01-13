class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def login_required
    if current_user.nil?
      respond_to do |format|
        format.html { redirect_to '/auth/aps' }
        # TODO: Agregar el response code http que corresponde (404??)
        format.json { render :json => { 'error' => 'Access Denied' }.to_json }
      end
    end
  end

  def current_user
    return nil unless session[:user_id]
    # TODO: Mmmm no seria mejor crear un token para recuperar el usuario de sesion?, caso contrario no se podria injectar info?
    @current_user ||= User.find_by_uid(session[:user_id]['uid'])
  end

end
