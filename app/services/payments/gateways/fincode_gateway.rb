# frozen_string_literal: true

module Payments
  module Gateways
    class FincodeGateway < BaseGateway
      def initialize(fincode_client = nil)
        @fincode_client = fincode_client || Payments::Gateways::FincodeClient.new
      end

      def register(amount:, user:)
        order_id = generate_order_id
        
        result = handle_errors do
          @fincode_client.register(
            order_id: order_id,
            amount: amount,
            customer_info: {
              email: user.email,
              name: user.display_name
            }
          )
        end

        {
          id: result['id'],
          access_id: result['access_id'],
          amount: amount
        }
      end

      def capture(order_id:, access_id:, amount:)
        handle_errors do
          @fincode_client.capture(
            order_id: order_id,
            access_id: access_id,
            amount: amount
          )
        end
      end

      def cancel(order_id:, access_id:)
        handle_errors do
          @fincode_client.cancel(
            order_id: order_id,
            access_id: access_id
          )
        end
      end

      def refund(order_id:, access_id:, amount:)
        result = handle_errors do
          @fincode_client.refund(
            order_id: order_id,
            access_id: access_id,
            amount: amount
          )
        end
        
        { id: result['id'] }
      end

      def handle_errors
        yield
      rescue Payments::Gateways::FincodeClient::FincodeError => e
        raise Payments::Error, e.message
      end

      private

      def generate_order_id
        "ORD_#{Time.current.to_i}_#{SecureRandom.hex(6)}"
      end
    end
  end
end
