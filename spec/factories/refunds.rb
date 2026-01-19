# frozen_string_literal: true

FactoryBot.define do
  factory :refund do
    association :payment
    association :processed_by, factory: :user
    
    amount { 1000 }
    reason { 'Customer requested refund' }
    status { :completed }
    processed_at { Time.current }
    fincode_refund_id { "r_#{SecureRandom.hex(16)}" }

    trait :pending do
      status { :pending }
      processed_at { nil }
    end

    trait :failed do
      status { :failed }
    end

    trait :partial do
      amount { payment.amount / 2 }
    end

    trait :full do
      amount { payment.amount }
    end
  end
end
