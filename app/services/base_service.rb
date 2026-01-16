# frozen_string_literal: true

class BaseService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  protected

  def validate_params!(params, required_keys)
    missing_keys = required_keys - params.keys.map(&:to_sym)
    raise ActionFailed, :invalid_params, missing_keys: missing_keys if missing_keys.any?
  end
end
