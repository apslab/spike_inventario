module OauthSignParser
  def valid?(request)
    headers = parse_headers(request)
    raise 'Invalid timestamp' unless valid_timestamp?( headers[:oauth_timestamp] )
    raise 'Invalid consumer key' unless valid_consumer_key?( headers[:oauth_consumer_key] )
    nonce = OauthNonce.remember(headers[:oauth_nonce], headers[:oauth_timestamp])
    raise 'Invalid authentication' unless nonce
    raise 'Invalid authentication' unless valid_sign?( request, headers )
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
  
  # The nonce value MUST be unique across all requests with the
  # same timestamp, client credentials, and token combinations.
  # (see: http://tools.ietf.org/html/rfc5849#page-17)
  def valid_nonce?(nonce, timestamp, consumer_key)
    
  end

  def signature_base_string(request)
   OAuth::Signature.build(request, {}).signature
  end
  
  # see http://tools.ietf.org/html/rfc5849#section-3.4.1.2
  def base_string_uri(request)
    schema = request.env['rack.url_scheme'] # http or https
    port = request.env['SERVER_PORT'].to_i
    if (port == 80 && schema == 'http') || (port == 443 && schema == 'https')
      host = request.env['SERVER_NAME'].downcase # like 192.168.1.1 (without port)
    else
      host = request.headers['Host'].downcase # like 192.168.1.1:3000
    end
    path_info = request.env['PATH_INFO'].empty? ? '/' : request.env['PATH_INFO']
    base_string = "#{schema}://#{host}#{path_info}"
  end

  REQUIRED_HEADERS = [:oauth_consumer_key, :oauth_token, :oauth_signature_method, :oauth_timestamp, :oauth_nonce, :oauth_signature]
end
