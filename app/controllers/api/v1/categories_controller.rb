# frozen_string_literal: true

module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :set_category, only: %i[show update destroy]

      def index
        categories = Category.page(params[:page]).per(params[:per_page] || 6)

        render_paginated_collection(categories)
      end

      def create
        category = Category.create!(category_params)

        render_created(category)
      end

      def show
        render_resource(category)
      end

      def update
        category.update!(category_params)

        render_updated(category)
      end

      def destroy
        category.destroy!

        render_deleted(Category)
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      attr_reader :category

      def category_params
        params.require(:category).permit(:name, :category_type, :icon)
      end
    end
  end
end
