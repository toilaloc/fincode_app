# frozen_string_literal: true

module Api
  module V1
    class CategorySerializer < ApplicationSerializer
      attributes :id, :name
    end
  end
end
