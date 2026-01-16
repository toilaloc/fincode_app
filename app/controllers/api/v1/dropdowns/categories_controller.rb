# frozen_string_literal: true

module Api
  module V1
    module Dropdowns
      class CategoriesController < ApplicationController
        def index
          categories = Category.select(:id, :name)

          render json: { categories: }
        end
      end
    end
  end
end
