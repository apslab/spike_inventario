module OauthSignParser
  def valid?(request)
    headers = parse_headers(request)
    raise 'Invalid timestamp' unless valid_timestamp?( headers[:oauth_timestamp] )
    raise 'Invalid consumer key' unless valid_consumer_key?( headers[:oauth_consumer_key] )
    raise 'Invalid authentication' unless valid_sign?( request, headers )
    raise 'Invalid authentication' unless valid_nonce?( headers[:oauth_nonce], headers[:oauth_timestamp])
    true
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

  def valid_timestamp?(timestamp)
    now = Time.now.utc
    requested = Time.at(timestamp.to_i).utc
    time_diff = now - requested    
    accepted_diff_time = 2 * 60 # two minutes
    return false if time_diff > accepted_diff_time || requested > now
    true
  end

  def client_application(consumer_key)
    ClientApplication.find_by_public_key(consumer_key)
  end

  REQUIRED_HEADERS = [:oauth_consumer_key, :oauth_token, :oauth_signature_method, :oauth_timestamp, :oauth_nonce, :oauth_signature]
end
