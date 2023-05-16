FactoryBot.define do
    factory :request do
      type_request {1}
      status {1}
      user
      device
    end
end
