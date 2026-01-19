module Payments
  module Gateways
    class FincodeClient
      include HTTParty

      base_uri ENV['FINCODE_API_URL']
      
      class FincodeError < StandardError; end

      # Initializes the Fincode API client.
      # Requires FINCODE_SECRET_KEY to be set in environment.
      # @raise [FincodeError] if API key is missing
      def initialize
        @secret_key = ENV['FINCODE_SECRET_KEY']

        raise FincodeError, 'FINCODE_SECRET_KEY is not configured' if @secret_key.blank?
      end

      # Creates a new payment session.
      #
      # @param order_id [String] Unique order identifier
      # @param amount [Integer] Payment amount
      # @param customer_info [Hash] Optional customer details (:email, :name)
      # @return [Hash] Response including access_id and order_id
      def register(order_id:, amount:, customer_info: {})
        response = self.class.post(
          '/v1/payments',
          headers: headers,
          body: {
            pay_type: 'Card',
            job_code: 'AUTH',
            amount: amount.to_s,
            tax: '0',
            id: order_id,
            client_field_1: customer_info[:email],
            client_field_2: customer_info[:name]
          }.to_json
        )

        handle_response(response)
      end

      # Captures an authorized payment.
      #
      # @param order_id [String] Unique order identifier
      # @param access_id [String] Access ID from registration
      # @param amount [Integer] Amount to capture (must match or be less than authorized)
      # @return [Hash] Capture details
      def capture(order_id:, access_id:, amount:)
        body_data = {
          pay_type: 'Card',
          access_id: access_id.to_s,
          amount: amount.to_s
        }

        response = self.class.put(
          "/v1/payments/#{order_id}/capture",
          headers: headers,
          body: body_data.to_json
        )

        handle_response(response)
      end

      # Cancel Authorization
      # API: PUT /v1/payments/{id}/cancel
      # IMPORTANT: Only used for cancelling AUTHORIZED payments (before capture).
      # Do NOT use this for refunds.
      #
      # @param order_id [String] Unique order identifier
      # @param access_id [String] Access ID from registration
      # @return [Hash] Cancellation details
      def cancel(order_id:, access_id:)
        response = self.class.put(
          "/v1/payments/#{order_id}/cancel",
          headers: headers,
          body: { 
            pay_type: 'Card',
            access_id: access_id.to_s 
          }.to_json
        )

        handle_response(response)
      end

      # Refund Payment
      # Note: According to Fincode support, there is no separate /refund endpoint.
      # We use /cancel for both canceling (void) and refunding.
      # The API behaves differently based on the current transaction state.
      #
      # @param order_id [String] Unique order identifier
      # @param access_id [String] Access ID from registration
      # @param amount [Integer] Amount to refund (optional)
      # @return [Hash] Refund details
      def refund(order_id:, access_id:, amount: nil)
        body_data = {
          pay_type: 'Card',
          access_id: access_id.to_s
        }
        # Note: If Fincode 'cancel' endpoint supports partial refund amount, we include it.
        # Otherwise this might always be a full refund depending on API spec.
        body_data[:amount] = amount.to_s if amount.present?

        response = self.class.put(
          "/v1/payments/#{order_id}/cancel",
          headers: headers,
          body: body_data.to_json
        )

        handle_response(response)
      end

      # Get Payment Details
      # API: GET /v1/payments/{id}
      #
      # @param order_id [String] Unique order identifier
      # @return [Hash] Payment details
      def find_payment(order_id:)
        response = self.class.get(
          "/v1/payments/#{order_id}",
          query: { pay_type: 'Card' },
          headers: headers
        )

        handle_response(response)
      end

      private

      # Secure authentication headers for Fincode API.
      #
      # content-type - application/json
      # authorization - Bearer {secret_key}
      #
      # Returns [Hash] request headers
      def headers
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@secret_key}"
        }
      end

      # Handles HTTP response from Fincode API.
      # Raises {FincodeError} on non-2xx status codes.
      #
      # @param response [HTTParty::Response] The raw response object
      # @return [Hash] Parsed JSON response body if successful
      # @raise [FincodeError] If the response status denotes an error
      def handle_response(response)
        case response.code
        when 200, 201
          response.parsed_response
        when 400
          errors = parse_errors(response)
          Rails.logger.error("Fincode 400: #{errors}")
          raise FincodeError, "Bad Request: #{errors}"
        when 401
          Rails.logger.error("Fincode 401: Unauthorized")
          raise FincodeError, "Unauthorized - Check your API credentials"
        when 403
          errors = parse_errors(response)
          Rails.logger.error("Fincode 403: Forbidden")
          raise FincodeError, "Forbidden - API key lacks permission: #{errors}"
        when 404
          raise FincodeError, "Payment not found"
        when 500..599
          Rails.logger.error("Fincode 5xx: Server error")
          raise FincodeError, "Fincode server error - Please try again later"
        else
          Rails.logger.error("Fincode #{response.code}: #{response.body}")
          raise FincodeError, "Payment processing failed (HTTP #{response.code})"
        end
      end

      # Extracts helpful error messages from Fincode's error response structure.
      #
      # @param response [HTTParty::Response] The raw response object
      # @return [String] A safe, human-readable error message
      def parse_errors(response)
        data = response.parsed_response
        return data['message'] if data.is_a?(Hash) && data['message']

        errors = data.is_a?(Hash) ? (data['errors'] || []) : []
        return errors.map { |e| e['error_message'] || e['message'] }.join(', ') if errors.any?

        'Unknown error'
      rescue StandardError => e
        Rails.logger.error("Error parsing response: #{e.message}")
        'Unknown error'
      end
    end
  end
end

