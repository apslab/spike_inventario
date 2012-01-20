class Customer
  include RestResource

  BASE_RESOURCE_URI = 'http://127.0.0.1:3001'
  PROVIDER_NAME = 'ventas'
  
  attr_accessor :id, :name

  def initialize(properties = {})
    unless properties.empty?
      self.id = properties['id'] || properties[:id]
      self.name = properties['name'] || properties[:name]
    end
  end
 
end
