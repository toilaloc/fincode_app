module Fincode
  class PaymentService
    include HTTParty

    base_uri ENV['FINCODE_API_URL']
    
    class FincodeError < StandardError; end

    def initialize
      @secret_key = ENV['FINCODE_SECRET_KEY']

      raise FincodeError, 'FINCODE_SECRET_KEY is not configured' if @secret_key.blank?
    end

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

    # FE already handles tokenization
    # this is no need to implement it here

    # def execute(order_id:, access_id:, token:, method: '1')
    #   body_data = {
    #     access_id: access_id.to_s,
    #     pay_type: 'Card',
    #     token: token.to_s,
    #     method: method.to_s
    #   }

    #   response = self.class.put(
    #     "/v1/payments/#{order_id}/execute",
    #     headers: headers,
    #     body: body_data.to_json
    #   )

    #   handle_response(response)
    # end

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

    def cancel(order_id:, access_id:)
      response = self.class.put(
        "/v1/payments/#{order_id}/cancel",
        headers: headers,
        body: { 
          access_id: access_id.to_s 
        }.to_json
      )

      handle_response(response)
    end

    def get_payment(order_id)
      response = self.class.get(
        "/v1/payments/#{order_id}",
        headers: headers
      )

      handle_response(response)
    end

    private

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@secret_key}"
      }
    end

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
