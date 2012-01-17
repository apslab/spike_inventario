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

  describe '#base_string_uri' do    
    def request_for_url(url)
      #match = /(http[s]?):\/\/(\w+)(\:(\d+))?((\/\w+)*)(\?\w+=\w+(&w+=w+)*)*/.match(url)
      query_striped = url.split("?")[0]
      split = query_striped.split("/")
      url_scheme = split[0].chop
      host = split[2]
      path_info = "/" + split[3..split.size].join("/")
      env = {
        'rack.url_scheme' => url_scheme,
        'SERVER_PORT' => host.split(":")[1],
        'SERVER_NAME' => host.split(":")[0],
        'PATH_INFO' => path_info
      }
      headers = { 'Host' => host }
      request = double
      request.stub(:env) { env }
      request.stub(:headers) { headers }
      request
    end

    it 'with http://EXAMPLE:80/r%20v/X?id=123 must be return http://example/r%20v/X' do
      request = request_for_url('http://EXAMPLE:80/r%20c/X?id=123')
      @parser.base_string_uri(request).should == 'http://example/r%20c/X'
    end

    it 'with https://EXAMPLE:443/clients must be return https://example/clients' do
      request = request_for_url('https://EXAMPLE:443/clients')
      @parser.base_string_uri(request).should == 'https://example/clients'
    end

    it 'with http://APP.TestApp:3000 must be return http://app.testapp:3000' do
      request = request_for_url('http://APP.TestApp:3000')
      @parser.base_string_uri(request).should == 'http://app.testapp:3000/'
    end

    it 'with http://www.google.com?q=test must be return http://www.google.com' do
      request = request_for_url('http://www.google.com?q=test')
      @parser.base_string_uri(request).should == 'http://www.google.com/'
    end

    it 'with https://www.application.com.ar/tester/new/flag?a=33&b= be return https://www.application.com.ar/tester/new/flag' do
      request = request_for_url('https://www.application.com.ar/tester/new/flag?a=33&b=')
      @parser.base_string_uri(request).should == 'https://www.application.com.ar/tester/new/flag'
    end

  end

  describe '#signature' do
    it 'do' do
      request = Net::HTTP::Get.new('/photos?file=vacation.jpg&size=original&oauth_version=1.0&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_token=nnch734d00sl2jdk&oauth_timestamp=1191242096&oauth_nonce=kllo9940pd9333jh&oauth_signature_method=HMAC-SHA1')
      puts @parser.signature_base_string(request)
    end
  end

end
