# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    display_name { Faker::Internet.username }
    email { Faker::Internet.email }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
  end
end
