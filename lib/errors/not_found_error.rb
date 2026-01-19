# frozen_string_literal: true

module Errors
  class NotFoundError < Errors::BaseError
    def self.status_code
      :not_found
    end
  end
end