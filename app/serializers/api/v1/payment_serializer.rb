# frozen_string_literal: true

module Api
  module V1
    class PaymentSerializer < ApplicationSerializer
      attributes :id, :fincode_order_id, :amount, :status, :authorized_at, :captured_at, :created_at, :updated_at

      belongs_to :user, serializer: UserSerializer
    end
  end
end