require 'spec_helper'

describe Oauth::Applications do

  let(:inventario) do
    { 'identifier' => '761e2621', 'secret' => '8740dbce820d968fe4c98a15cf1dd309' } 
  end
  let(:app2) do
    { 'identifier' => 'aaaabbbb', 'secret' => '12345678901234567890123456789012' }    
  end

  let(:applications) do
    applications = Oauth::Applications
    YAML.stub!(:load_file) do
      { 
        Rails.env => { 
          'inventario' => inventario,
          'app2' => app2 
        }
      }
    end
    applications
  end

  subject { applications }

  describe "#by_name" do
    context "with parameter 'inventario'" do
      subject { applications.by_name('inventario') }
      it { should_not be_nil }
      it { should be_a(Oauth::Applications::Credential) }
      its(:app_name) { should == 'inventario' }
      its(:identifier) { should == inventario['identifier'] }
      its(:secret) { should == inventario['secret'] }
    end

    context "with inexistent name" do
      subject { applications.by_name('nnnn') } 
      it { should be_nil }
    end
  end

  describe "#by_identifier" do 
    context "with parameter 'app2'" do
      subject { applications.by_identifier('aaaabbbb') }
      it { should_not be_nil }
      it { should be_a(Oauth::Applications::Credential) }
      its(:app_name) { should == 'app2' }
      its(:identifier) { should == app2['identifier'] }
      its(:secret) { should == app2['secret'] }
    end
    context 'with inexistent identifier' do
      subject { applications.by_identifier('nnnn') }
      it { should be_nil }
    end
  end
  
end
