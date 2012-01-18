module RestResource

  module ClassMethodsRestResource  
    def find(id)
      return nil if id.nil?
      hash = invoke(:get, "/#{id}")
      name.constantize.new(hash)
      rescue RestClient::ResourceNotFound
        # use ActiveResource::ResourceNotFound from rails?
        raise 'Resource not found'
    end

    def all
      hashes = invoke(:get)
      model = name.constantize
      hashes.map { |hash| model.new(hash) }      
    end

    def resource_name
      name.tableize
    end

    def resource_url
      "#{base_path}/#{resource_name}"
    end

    def base_path
      @base_path ||= const_defined?(:BASE_RESOURCE_URI) ? const_get(:BASE_RESOURCE_URI) : 'http://127.0.0.1:3000'
    end

    private

    def invoke(action, extend_path = nil)
      url = extend_path.nil? ? resource_url : resource_url + extend_path
      puts "invoking #{url}"
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
          oauth_helper = OAuth::Client::Helper.new(req, {:consumer => consumer, :request_uri => params[:url]})
          req["Authorization"] = oauth_helper.header
        end
      end
    end

    def consumer
      # TODO: Pasar secret and client a properties o bbdd
      secret = '8740dbce820d968fe4c98a15cf1dd309'
      client = '761e2621'
      OAuth::Consumer.new(client, secret)
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


