class RestResource

  def self.find(id)
    return nil if id.nil?
    hash = invoke(:get, "/#{id}")
    initialize_resource(hash)
    rescue RestClient::ResourceNotFound
      raise 'Resource not found'
  end

  def self.all
    hashes = invoke(:get)
    hashes.map { |hash| initialize_resource(hash) }
  end

  def self.resource_name(resource_name = nil)
    @resource_name = resource_name unless resource_name.blank?
    (@resource_name || name).tableize
  end

  def self.resource_url(resource_url = nil)
    @resource_url = resource_url unless resource_url.blank?
    #raise 'You must specify the constant resource_url in the resource class' unless @resource_url
    @resource_url
  end

  def self.provider(provider = nil)
    @provider = provider unless provider.blank?
    raise 'You must specify the constant provider in the resource class' unless @provider
    Oauth::Applications.by_name(@provider)
  end

  private

  def self.initialize_resource(hash)
    instance = name.constantize.new
    hash.each do |param, value|
      setter_method = "#{param.to_sym}="
      instance.public_send(setter_method, value) if instance.respond_to?(setter_method) 
    end
    instance
  end

  def self.ws_url(extend_path = nil)
    url = resource_url
    if url.nil?
      url = provider.url.clone
      url << "/" unless url.last == "/"
      url << resource_name
    end
    url << extend_path unless extend_path.nil?
    url
  end

  def self.invoke(action, extend_path = nil)
    add_oauth_authorization
    url = ws_url(extend_path)
    response = RestClient.send(action, url, :accept => :json) 
    ActiveSupport::JSON.decode(response.body)
    #rescue Errno::ECONNREFUSED => ex
    #  logger.error "GROSO ERROR!"
    #  raise ex
  end

  def self.add_oauth_authorization
    if RestClient.before_execution_procs.empty?
      RestClient.add_before_execution_proc do |req, params|
        #web_service = Oauth::Applications.by_name(provider)
        #consumer = OAuth::Consumer.new(web_service.identifier, web_service.secret)
        consumer = OAuth::Consumer.new(provider.identifier, provider.secret)
        oauth_helper = OAuth::Client::Helper.new(req, {:consumer => consumer, :request_uri => params[:url]})
        req["Authorization"] = oauth_helper.header
      end
    end
  end

end

