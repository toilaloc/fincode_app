# frozen_string_literal: true

module Payments
  class Processor
    attr_reader :current_user, :gateway

    def initialize(current_user, gateway: nil)
      @current_user = current_user
      @gateway = gateway || Payments::Gateways::FincodeGateway.new
    end

    def register_payment(amount:)
      validate_amount!(amount)
      
      public_key = ENV.fetch('FINCODE_PUBLIC_KEY')
      
      result = gateway.register(
        amount: amount,
        user: current_user
      )

      payment = Payment.create!(
        user: current_user,
        fincode_order_id: result[:id],
        fincode_access_id: result[:access_id],
        amount: amount,
        status: :pending,
        authorized_at: nil,
        customer_email: current_user.email
      )

      {
        order_id: payment.fincode_order_id,
        access_id: payment.fincode_access_id,
        amount: payment.amount,
        public_key: public_key
      }
    end

    def confirm_payment(payment_id:)
      payment = find_payment!(payment_id)

      payment.update!(
        status: :authorized,
        authorized_at: Time.current
      )

      {
        payment_id: payment.id,
        status: payment.status,
        authorized_at: payment.authorized_at,
        amount: payment.amount
      }
    end

    def capture_payment(payment_id:)
      payment = find_payment!(payment_id)
      
      validate_can_capture!(payment)

      gateway.capture(
        order_id: payment.fincode_order_id,
        access_id: payment.fincode_access_id,
        amount: payment.amount
      )

      payment.update!(
        status: :captured,
        captured_at: Time.current
      )

      {
        payment_id: payment.id,
        status: payment.status,
        captured_at: payment.captured_at,
        amount: payment.amount
      }
    end

    def cancel_payment(payment_id:)
      payment = find_payment!(payment_id)
      
      validate_can_cancel!(payment)

      gateway.cancel(
        order_id: payment.fincode_order_id,
        access_id: payment.fincode_access_id
      )

      payment.update!(
        status: :cancelled,
        canceled_at: Time.current
      )

      {
        payment_id: payment.id,
        status: payment.status,
        canceled_at: payment.canceled_at,
        amount: payment.amount
      }
    end

    def refund_payment(payment_id:, amount: nil, reason: nil)
      payment = find_payment!(payment_id)
      
      validate_can_refund!(payment)

      refund_amount = amount || payment.amount
      validate_refund_amount!(payment, refund_amount)

      result = gateway.refund(
        order_id: payment.fincode_order_id,
        access_id: payment.fincode_access_id,
        amount: refund_amount
      )

      refund = Refund.create!(
        payment: payment,
        amount: refund_amount,
        reason: reason,
        status: :completed,
        processed_by: current_user,
        processed_at: Time.current,
        fincode_refund_id: result[:id]
      )

      update_payment_after_refund!(payment, refund_amount)

      {
        refund_id: refund.id,
        payment_id: payment.id,
        amount: refund_amount,
        status: refund.status,
        remaining_amount: payment.refundable_amount
      }
    end

    def list_payments
      current_user.payments.order(created_at: :desc)
    end

    def find_payment(payment_id)
      current_user.payments.find_by(fincode_order_id: payment_id)
    end

    private

    def find_payment!(payment_id)
      payment = find_payment(payment_id)
      raise Payments::NotFoundError, 'Payment not found' unless payment
      
      payment
    end

    def validate_amount!(amount)
      raise Payments::ValidationError, 'Invalid amount' if amount.nil? || amount < 100
    end

    def validate_can_capture!(payment)
      return if payment.status == 'authorized'
      
      raise Payments::ValidationError, 'Payment must be authorized to capture'
    end

    def validate_can_cancel!(payment)
      return if payment.can_cancel?
      
      raise Payments::ValidationError, 'Payment cannot be cancelled'
    end

    def validate_can_refund!(payment)
      return if payment.can_refund?
      
      raise Payments::ValidationError, 'Only captured payments can be refunded'
    end

    def validate_refund_amount!(payment, refund_amount)
      remaining = payment.refundable_amount

      if refund_amount > remaining
        raise Payments::ValidationError, "Refund amount exceeds remaining amount (¥#{remaining})"
      end

      raise Payments::ValidationError, 'Refund amount must be greater than 0' if refund_amount <= 0
    end

    def update_payment_after_refund!(payment, refund_amount)
      new_status = if fully_refunded?(payment, refund_amount)
                     :refunded
                   else
                     :partially_refunded
                   end

      payment.update!(
        status: new_status,
        refunded_at: Time.current
      )
    end

    def fully_refunded?(payment, refund_amount)
      total_refunded = payment.total_refunded + refund_amount
      total_refunded >= payment.amount
    end
  end
end

