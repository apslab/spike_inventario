# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :client_application do
    public_key SecureRandom.hex(8)
    secret_key SecureRandom.hex(16)
  end
end
