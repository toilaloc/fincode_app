# frozen_string_literal: true


class ApplicationController < ActionController::API
  include ApiResponse
  before_action :authenticate_request, :authenticate_user!

  attr_reader :current_user

  rescue_from StandardError, with: :render_error
  rescue_from Errors::BaseError, with: :render_error
  rescue_from Payments::NotFoundError, with: :render_payment_not_found
  rescue_from Payments::ValidationError, with: :render_payment_validation_error
  rescue_from Payments::Error, with: :render_payment_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_error
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_json_parse_error
  rescue_from ArgumentError, with: :render_argument_error

  private

  def authenticate_request
    token = extract_token_from_header
    raise ActionFailed, :unauthorized unless token

    magic_link_service = MagicLinkService.new
    @current_user = magic_link_service.verify_and_extend_access_token(token)
  end

  def authenticate_user!
    raise ActionFailed, :unauthorized unless current_user
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    return nil unless header

    header.split(' ').last if header.start_with?('Bearer ')
  end

  def current_access_token
    extract_token_from_header
  end

  def render_json_parse_error(exception)
    Rails.logger.error "JSON Parse Error: #{exception.message}"

    render json: {
      error: 'Invalid JSON format',
      message: 'The request body contains invalid JSON. Please check your syntax.'
    }, status: :bad_request
  end

  def render_argument_error(exception)
    Rails.logger.error "Argument Error: #{exception.message}"

    render json: {
      error: 'Invalid parameter value',
      message: exception.message
    }, status: :unprocessable_entity
  end

  def render_error(exception)
    error_response = ErrorFormatterService.format_error(exception)

    Rails.logger.error "#{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?

    render error_response
  end

  def render_payment_not_found(exception)
    render json: { success: false, error: exception.message }, status: :not_found
  end

  def render_payment_validation_error(exception)
    render json: { success: false, error: exception.message }, status: :unprocessable_entity
  end

  def render_payment_error(exception)
    render json: { success: false, error: exception.message }, status: :unprocessable_entity
  end
end
