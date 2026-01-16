# frozen_string_literal: true

FactoryBot.define do
  factory :payments do
    association :user
    association :category
    amount { 100.0 }
    transaction_date { Date.today }
    note { Faker::Lorem.sentence }
  end
end
