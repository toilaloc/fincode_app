# frozen_string_literal: true

module Errors
  class BaseError < StandardError
    attr_reader :error_code, :status, :details

    def initialize(error_code, details = {})
      @error_code = error_code
      @details = details
      @status = self.class.status_code
      super(message)
    end

    def message
      I18n.t(i18n_key, **details.merge(default: default_message))
    end

    def error_type
      self.class.name.demodulize.underscore.gsub(/_error$/, '')
    end

    private

    def i18n_key
      "errors.#{error_type}.#{error_code}"
    end

    def default_message
      error_code.to_s.humanize
    end

    def self.status_code
      :bad_request
    end
  end
end
