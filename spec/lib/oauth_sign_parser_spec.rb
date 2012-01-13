require 'spec_helper'
require File.expand_path("#{Rails.root}/lib/oauth_sign_parser")

describe OauthSignParser do
  
  class OauthDummyClass
    include OauthSignParser
  end
  
  let(:request) do
    request = double()
    request.stub(:headers) { headers }
    request
  end

  let(:headers) do
    headers = stub('hash')
    headers.stub(:[]).with('Authorization').and_return(oauth_header(oauth_header_hash))
    headers
  end

  #let(:oauth_header) do
  #  'OAuth ' << oauth_header_hash.map{ |key, value| "#{key.to_s}=\"#{value}\"" }.join(", ")
  #end

  let(:oauth_header_hash) do
    { 
      :realm => 'Photos',
      :oauth_consumer_key => 'dpf43f3p2l4k3l03',
      :oauth_token => '',
      :oauth_signature_method => 'HMAC-SHA1',
      :oauth_timestamp => '137131200',
      :oauth_nonce => 'wIjqoS',
      :oauth_signature => '74KNZJeDHnMBp0EMJ9ZHt%2FXKycU%3D'      
    }
  end

  def oauth_header(hash)
    'OAuth ' << oauth_header_hash.map{ |key, value| "#{key.to_s}=\"#{value}\"" }.join(", ")
  end

  def build_headers(hash)
    headers = stub('hash')
    headers.stub(:[]).with('Authorization').and_return(oauth_header(hash))
    headers
  end
  
  before(:each) { @parser = OauthDummyClass.new }

  describe "parse headers" do
    it "should raise exception if header 'Authorization' is not present" do
      headers = stub('hash')
      headers.stub(:[]).with('Authorization').and_return(nil)
      request.stub(:headers) { headers }
      expect { @parser.parse_headers(request) }.to raise_error('Authorization header not present')
    end
    
    context 'The headers not contains all the required parameters' do
      it 'should raise exception' do
        oauth_header_hash.delete(:oauth_consumer_key)
        expect { @parser.parse_headers(request) }.to raise_error('Missing required parameter')
      end
    end

    it "should return a hash with oauth authorization values" do
      @parser.parse_headers(request).should == oauth_header_hash
    end

  end

end
