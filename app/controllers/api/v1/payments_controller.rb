class Api::V1::PaymentsController < ApplicationController
  before_action :set_payment_service

  def index
    payments = @payment_service.list_payments
    render_collection(payments)
  end

  def register
    amount = params[:amount].to_i
    result = @payment_service.register_payment(amount: amount)

    render json: {
      success: true,
      **result
    }
  end

  def show
    payment = @payment_service.find_payment(params[:id])
    raise Payments::NotFoundError, 'Payment not found' unless payment

    render json: { success: true, payment: payment }
  end

  def cancel
    result = @payment_service.cancel_payment(payment_id: params[:id])

    render json: {
      success: true,
      **result,
      message: 'Payment cancelled successfully'
    }
  end

  # This just update status to sync with fincode status
  def confirm
    result = @payment_service.confirm_payment(payment_id: params[:id])

    render json: {
      success: true,
      **result
    }
  end

  def capture
    result = @payment_service.capture_payment(payment_id: params[:id])

    render json: {
      success: true,
      **result,
      message: 'Payment captured successfully'
    }
  end

  def refund
    result = @payment_service.refund_payment(
      payment_id: params[:id],
      amount: params[:amount]&.to_i,
      reason: params[:reason]
    )

    render json: {
      success: true,
      **result,
      message: 'Refund processed successfully'
    }
  end

  private

  def set_payment_service
    @payment_service = Payments::Processor.new(current_user)
  end
end

