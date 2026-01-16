class Api::V1::PaymentsController < ApplicationController
  skip_before_action :authenticate_request, :authenticate_user!, only: [:create]
  before_action :set_payment, only: [:show, :capture, :cancel]

  def index
    payments = current_user.payments.includes(:order).order(created_at: :desc)
    render_collection(payments)
  end

  def register
    order_id = generate_order_id
    amount = params[:amount].to_i
    raise ActionController::BadRequest, 'Invalid amount' if amount < 100

    public_key = ENV['FINCODE_PUBLIC_KEY']

    result = fincode_payment_service.register(
      order_id: order_id,
      amount: amount,
      customer_info: {
        email: current_user.email,
        name: current_user.display_name
      }
    )

    payment = Payment.create!(
      user: current_user,
      fincode_order_id: result['id'],
      fincode_access_id: result['access_id'],
      amount: amount,
      status: :pending,
      customer_email: current_user.email
    )

    render json: {
      success: true,
      order_id: payment.fincode_order_id,
      access_id: payment.fincode_access_id,
      amount: payment.amount,
      public_key: public_key
    }

  rescue Fincode::PaymentService::FincodeError => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def execute
    payment = Payment.find_by!(fincode_order_id: params[:order_id])

    unless payment.user_id == current_user.id
      return render json: { success: false, error: 'Unauthorized' }, status: :forbidden
    end

    if payment.authorized? || payment.captured?
      return render json: { success: false, error: 'Already executed' }, status: :unprocessable_entity
    end

    result = fincode_payment_service.execute(
      order_id: payment.fincode_order_id,
      access_id: payment.fincode_access_id,
      token: params[:token]
    )

    payment.update!(
      status: :authorized,
      fincode_transaction_id: result['id'],
      authorized_at: Time.current
    )

    render json: { success: true, payment: payment }

  rescue Fincode::PaymentService::FincodeError => e
    payment&.update(status: :failed, error_message: e.message)
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def show
    render json: { success: true, payment: @payment }
  end

  def cancel
    unless @payment.can_cancel?
      return render json: { 
        success: false, 
        error: "Cannot cancel payment with status: #{@payment.status}" 
      }, status: :unprocessable_entity
    end

    result = fincode_payment_service.cancel(
      order_id: @payment.fincode_order_id,
      access_id: @payment.fincode_access_id
    )

    @payment.update!(status: :cancelled, cancelled_at: Time.current)

    render json: { 
      success: true, 
      payment: @payment,
      message: 'Payment cancelled successfully'
    }
  rescue Fincode::PaymentService::FincodeError => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  # confirm and capture payment
  def capture
    payment = Payment.find_by!(fincode_order_id: params[:order_id])
    
    unless payment.user_id == current_user.id
      return render json: { success: false, error: 'Unauthorized' }, status: :forbidden
    end

    if payment.authorized? || payment.captured?
      return render json: { 
        success: false, 
        error: "Payment already processed. Status: #{payment.status}" 
      }, status: :unprocessable_entity
    end

    payment.update!(
      status: :authorized,
      authorized_at: Time.current
    )

    capture_result = fincode_payment_service.capture(
      order_id: payment.fincode_order_id,
      access_id: payment.fincode_access_id,
      amount: payment.amount
    )

    payment.update!(status: :captured, captured_at: Time.current)

    render json: { 
      success: true, 
      payment: payment,
      message: 'Payment authorized and captured successfully'
    }
    
  rescue Fincode::PaymentService::FincodeError => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  private

  def set_payment
    @payment = current_user.payments.find_by!(fincode_order_id: params[:order_id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Not found' }, status: :not_found
  end

  def generate_order_id
    "ORD_#{Time.current.to_i}_#{SecureRandom.hex(6)}"
  end

  def fincode_payment_service
    @fincode_payment_service ||= Fincode::PaymentService.new
  end
end
