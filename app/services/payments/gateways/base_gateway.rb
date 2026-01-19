# frozen_string_literal: true

module Payments
  module Gateways
    class BaseGateway
      # @param amount [Integer]
      # @param user [User]
      # @return [Hash] { id: String, access_id: String, ... }
      def register(amount:, user:)
        raise NotImplementedError
      end

      # @param order_id [String]
      # @param access_id [String]
      # @param amount [Integer]
      # @return [Hash]
      def capture(order_id:, access_id:, amount:)
        raise NotImplementedError
      end

      # @param order_id [String]
      # @param access_id [String]
      def cancel(order_id:, access_id:)
        raise NotImplementedError
      end

      # @param order_id [String]
      # @param access_id [String]
      # @param amount [Integer]
      # @return [Hash]
      def refund(order_id:, access_id:, amount:)
        raise NotImplementedError
      end
    end
  end
end
