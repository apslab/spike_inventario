require 'spec_helper'

describe ClientApplication do
  before(:all){ @client = ClientApplication.new }

  subject { @client }

  it { should respond_to :public_key }
  it { should respond_to :secret_key }

  it { should validate_presence_of :public_key }

  before { ClientApplication.create!(:public_key => SecureRandom.hex(8)) }
  it { should validate_uniqueness_of :public_key }

  it { should ensure_length_of(:public_key).is_equal_to(16) }

  describe 'static method #build_random' do
   subject { ClientApplication.build_random }
   its(:public_key) { should be_present }
   its(:secret_key) { should be_present }
  end


end
