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

    [:oauth_consumer_key, :oauth_token, :oauth_signature_method, :oauth_timestamp, :oauth_nonce, :oauth_signature].each do |required_header| 
      it "should rise exception if Authorization header don't contains #{required_header}"  do
        oauth_header_hash.delete(required_header)
        expect { @parser.parse_headers(request) }.to raise_error('Missing required parameter')
      end
    end
    

    it "should return a hash with oauth authorization values" do
      @parser.parse_headers(request).should == oauth_header_hash
    end

  end

  describe 'check auth expiration' do

    context 'should invalid if' do
      it 'more than 2 minutes older' do                
        auth_timestamp = Time.now - 2.minutes - 1.second
        @parser.valid_timestamp?(auth_timestamp).should be_false
      end

      it 'before now' do        
        auth_timestamp = Time.now + 1.second
        @parser.valid_timestamp?(auth_timestamp).should be_false
      end      
    end

    it 'should be valid if less than 2 minutes' do
      @parser.valid_timestamp?(Time.now - 1.minutes).should be_true
    end
  end

  describe 'check consumer key' do
    before(:all) do
      DatabaseCleaner.strategy = :truncation      
      DatabaseCleaner.start
      @client_app =  create(:client_application, :public_key => 'dpf43f3p2l4k3l03') 
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it 'should belong to an existing client application' do
      @parser.client_application('dpf43f3p2l4k3l03').should == @client_app
    end

    it 'should return nil if consumer key dont exists' do
      @parser.client_application('aaasadsadadsadsad').should be_nil
    end

  end

end
