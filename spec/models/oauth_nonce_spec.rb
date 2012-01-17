require 'spec_helper'

describe OauthNonce do
  before(:all) do
    @nonce = OauthNonce.remember(SecureRandom.hex(4), Time.now.to_i) 
  end

  subject { @nonce }

  it { should respond_to :nonce }
  it { should respond_to :timestamp }
  it { should be_valid }
  it 'should not allow a second one with the same values' do
    OauthNonce.remember(@nonce.nonce, @nonce.timestamp).should be_false
  end

end
