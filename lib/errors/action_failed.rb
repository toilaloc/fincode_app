# frozen_string_literal: true

module Errors
  class ActionFailed < Errors::BaseError
    def self.status_code
      :unauthorized
    end
  end
end
