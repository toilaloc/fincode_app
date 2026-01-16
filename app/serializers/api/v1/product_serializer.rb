# frozen_string_literal: true

module Api
  module V1
    class ProductSerializer < ApplicationSerializer
      attributes :id, :user_id, :price
    end
  end
end
