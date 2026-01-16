# frozen_string_literal: true

module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: %i[show]

      def index
        products = Product.page(params[:page]).per(params[:per_page] || 10)
        render_paginated_collection(products)
      end

      def show
        render_resource(product)
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      attr_reader :product
    end
  end
end
