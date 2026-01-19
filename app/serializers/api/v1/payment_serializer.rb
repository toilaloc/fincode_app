# frozen_string_literal: true

module Api
  module V1
    class PaymentSerializer < ApplicationSerializer
      attributes :id, :fincode_order_id, :amount, :status, :authorized_at, :captured_at, :canceled_at, :refunded_at, :created_at, :updated_at, :refunds

      belongs_to :user, serializer: UserSerializer

      def refunds
        object.refunds.order(created_at: :desc).map do |refund|
          {
            id: refund.id,
            amount: refund.amount,
            reason: refund.reason,
            status: refund.status,
            processed_at: refund.processed_at
          }
        end
      end
    end
  end
end