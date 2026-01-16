# frozen_string_literal: true

module Errors
  class Runtime < Errors::BaseError
    def self.status_code
      :internal_server_error
    end
  end
end
