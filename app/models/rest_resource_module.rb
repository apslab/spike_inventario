module RestResourceModule

  module ClassMethodsRestResource  
    def find(id)
      return nil if id.nil?
      hash = invoke(:get, "/#{id}")
      initialize_resource(hash)
      #name.constantize.new(hash)
      rescue RestClient::ResourceNotFound
        # use ActiveResource::ResourceNotFound from rails?
        raise 'Resource not found'
    end

    def all
      hashes = invoke(:get)
      #model = name.constantize
      #hashes.map { |hash| model.new(hash) }      
      hashes.map { |hash| initialize_resource(hash) }
    end

    def resource_name
      const_defined?(:RESOURCE_NAME) ? const_get(:RESOURCE_NAME).tableize : name.tableize
    end

    def base_resource_uri=(base_resource_uri)
      @@base_resource_uri = base_resource_uri
    end

    def resource_url
      puts "base resource uri: #{@@base_resource_uri}"
      "#{base_path}/#{resource_name}"
    end

    def base_path
      raise 'You must specify the constant BASE_RESOURCE_URI in the resource class' unless const_defined?(:BASE_RESOURCE_URI)
      self.const_get(:BASE_RESOURCE_URI)
    end
    
    def provider_name
      raise 'You must specify the constant PROVIDER_NAME in the resource class' unless const_defined?(:PROVIDER_NAME)
      const_get(:PROVIDER_NAME)
    end

    private

    def initialize_resource(hash)
      instance = name.constantize.new
      hash.each do |param, value|
        puts "#{param}: #{value}"
        setter_method = "#{param.to_sym}="
        instance.public_send(setter_method, value) if instance.respond_to?(setter_method) 
      end
      instance
    end

    def invoke(action, extend_path = nil)
      url = extend_path.nil? ? resource_url : resource_url + extend_path
      add_oauth_authorization
      response = RestClient.send(action, url, :accept => :json) 
      ActiveSupport::JSON.decode(response.body)
      #rescue Errno::ECONNREFUSED => ex
      #  logger.error "GROSO ERROR!"
      #  raise ex
    end

    def add_oauth_authorization
      if RestClient.before_execution_procs.empty?
        RestClient.add_before_execution_proc do |req, params|
          credential = Oauth::Applications.by_name(provider_name)
          consumer = OAuth::Consumer.new(credential.identifier, credential.secret)
          oauth_helper = OAuth::Client::Helper.new(req, {:consumer => consumer, :request_uri => params[:url]})
          req["Authorization"] = oauth_helper.header
        end
      end
    end

    
    def products
      RestClient.reset_before_execution_procs
      consumer = OAuth::Consumer.new(SecureRandom.hex(4), SecureRandom.hex(16))
      oauth_params = {:consumer => consumer}
      RestClient.add_before_execution_proc do |req, params|
        oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => params[:url]))
        req["Authorization"] = oauth_helper.header # Signs the request
      end
      RestClient.get 'http://127.0.0.1:3000/products'
    end

  
  end

  include ClassMethodsRestResource

  def self.included(host_class)
    host_class.extend(ClassMethodsRestResource)
  end
    
  private

  def resource_name
    self.class.name.tableize
  end

end


