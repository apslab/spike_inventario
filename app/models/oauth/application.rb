class Oauth::Application < ActiveRecord::Base
  set_table_name :oauth_applications

  validates :public_key, :presence => true, :uniqueness => true, :length => { :is => 16 }

  def self.build_random
    # http://rubydoc.info/stdlib/securerandom/1.9.2/SecureRandom#hex-class_method
    # The argument n specifies the length of the random length. The length of the result string is twice of n.
    self.new(:public_key => SecureRandom.hex(8), :secret_key => SecureRandom.hex(16))
  end
end
