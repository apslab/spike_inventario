class Consumer
  def products
    RestClient.reset_before_execution_procs
    consumer = OAuth::Consumer.new(SecureRandom.hex(4), SecureRandom.hex(16))
    oauth_params = {:consumer => consumer}
    RestClient.add_before_execution_proc do |req, params|
        puts "Clase: #{req.class}"
        oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => params[:url]))
        puts oauth_helper.header
        req["Authorization"] = oauth_helper.header # Signs the request
    end
    RestClient.get 'http://127.0.0.1:3000/products'
  end
end
