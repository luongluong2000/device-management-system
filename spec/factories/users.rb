FactoryBot.define do
    factory :user do
      email {Faker::Internet.email(domain: "gmail.com")}
      password {Faker::Number.number(digits: 10)}
      first_name {Faker::Name.first_name}
      last_name {Faker::Name.last_name}
      office

      factory :user_bod do
        role {:bod}
      end
      factory :user_system_admin do
        role {:system_admin}
      end
      factory :user_device_manager do
        role {:device_manager}
      end
    end
end
