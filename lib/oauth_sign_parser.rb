module OauthSignParser
  def valid?(request)
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

  def parse_headers(request)
    auth_header = request.headers['Authorization']
    if auth_header.blank?
      raise 'Authorization header not present'
    end
    auths = {}
    auth_header.scan(/(\w*)=\"([^,\"]*)\"/){|key,value| auths[key.to_sym] = value }
    raise 'Missing required parameter' unless REQUIRED_HEADERS.all? { |key| auths.has_key? key }
    return auths
  end

  REQUIRED_HEADERS = [:oauth_consumer_key, :oauth_token, :oauth_signature_method, :oauth_timestamp, :oauth_nonce]
end
