# frozen_string_literal: true

module Payments
  class Error < StandardError; end
  class ValidationError < Error; end
  class NotFoundError < Error; end
end
