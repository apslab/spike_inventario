require 'spec_helper'

describe Oauth::Application do
  before(:all){ @client = Oauth::Application.create!(:public_key => SecureRandom.hex(4), :secret_key => SecureRandom.hex(16)) }

  subject { @client }

  it { should respond_to :public_key }
  it { should respond_to :secret_key }

  it { should validate_presence_of :public_key }
  it { should validate_presence_of :secret_key }
 
  it { should validate_uniqueness_of :public_key }

  it { should ensure_length_of(:public_key).is_equal_to(8) }
  it { should ensure_length_of(:secret_key).is_equal_to(32) }

  describe 'static method #build_random' do
   subject { Oauth::Application.build_random }
   its(:public_key) { should be_present }
   its(:secret_key) { should be_present }
  end


end
