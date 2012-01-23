class Customer < RestResource

  resource_url 'http://127.0.0.1:3001/customers'
 # BASE_RESOURCE_URI = 'http://127.0.0.1:3001'
  #PROVIDER_NAME = 'ventas'
  provider 'ventas'
  
  attr_accessor :id, :name
 
end
