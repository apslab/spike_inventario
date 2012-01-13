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

  def user_from_signed_request
    auth_header = request.headers['Authorization']
    if auth_header.blank?
      logger.debug 'Authorization header not present'
      return nil
    end
    auths = {}
    auth_header.scan(/(\w*)=\"([^,\"]*)\"/){|key,value| auths[key.to_sym] = value }
    # oauth keys:
    #   oauth_consumer_key: consumer public key
    #   oauth_token: Not used
    #   oauth_signature_method: "HMAC-SHA1", "RSA-SHA1", and "PLAINTEXT"
    #   oauth_timestamp: epoch (Time.now.to_i.to_s)
    #   oauth_nonce: check uniqueness
    #   oauth_version: 1.0
    unless [:oauth_consumer_key, :oauth_timestamp, :oauth_nonce].all? { |key| auths.has_key? key }
      logger.debug 'Missing some oauth keys in Authorization header'
      return nil
    end
    time_diff = Time.now - Time.at(auths[:oauth_timestamp].to_i)
    accepted_diff_time = 2 * 60 # two minutes
    if time_diff > accepted_diff_time
      logger.debug 'Expired request signed'
      return nil
    end
    unless valid_sign_request
      logger.debug 'Invalid request'
      return nil
    end
    User.find_by_uid(request.params['current_user_uid'])
  end


end
