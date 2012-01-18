class Customer
  include RestResource
  #include ActiveModel::AttributeMethods  
  #include ActiveModel::Serializers::JSON

  BASE_RESOURCE_URI = 'http://127.0.0.1:3001'
  
  attr_accessor :id, :name

  def initialize(properties = {})
    unless properties.empty?
      self.id = properties['id'] || properties[:id]
      self.name = properties['name'] || properties[:name]
      #self.created_at = properties['created_at'] || properties[:created_at]
      #self.updated_at = properties['updated_at'] || properties[:updated_at]
    end
  end
 
end
