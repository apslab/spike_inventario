# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :oauth_nonce do
    nonce "MyString"
    timestamp 1
  end
end
