# frozen_string_literal: true

class ErrorFormatterService
  def self.format_error(exception)
    case exception
    when Errors::BaseError
      {
        json: {
          error: exception.error_type.humanize,
          message: exception.message
        },
        status: exception.status
      }
    when ActiveRecord::RecordInvalid
      {
        json: {
          errors: exception.record.errors.map do |error|
            {
              field: error.attribute.to_s,
              message: error.message
            }
          end
        },
        status: :unprocessable_entity
      }
    when ActiveRecord::RecordNotFound
      {
        json: {
          error: 'Not Found',
          message: exception.message
        },
        status: :not_found
      }
    else
      {
        json: {
          error: 'Internal Server Error',
          message: Rails.env.development? ? exception.message : 'An unexpected error occurred'
        },
        status: :internal_server_error
      }
    end
  end
end
