# frozen_string_literal: true

module Errors
  class ServiceFailed < Errors::BaseError
    def self.status_code
      :unprocessable_entity
    end
  end
end
