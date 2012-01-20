class Oauth::Application < ActiveRecord::Base
  set_table_name :oauth_applications

  validates :public_key, :presence => true, :uniqueness => true, :length => { :is => 8 }
  validates :secret_key, :presence => true, :length => { :is => 32 }
  
  def self.build_random
    # http://rubydoc.info/stdlib/securerandom/1.9.2/SecureRandom#hex-class_method
    # The argument n specifies the length of the random length. The length of the result string is twice of n.
    self.new(:public_key => SecureRandom.hex(4), :secret_key => SecureRandom.hex(16))
  end

end
