# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < ApplicationSerializer
      attributes :id, :display_name, :email
    end
  end
end
