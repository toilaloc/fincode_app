# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_request, :authenticate_user!, only: [:create]
      before_action :user, only: %i[show update destroy]
      before_action :authorize_user, only: %i[update destroy]

      def create
        created_user = User.create!(user_params)

        UserMailer.welcome_email(created_user).deliver_later

        render_created(created_user)
      end

      def show
        render_resource(user)
      end

      def update
        user.update!(user_params)
        render_updated(user)
      end

      def destroy
        user.destroy!

        render_deleted(User)
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :display_name, :email, :password, :password_confirmation, :avatar)
      end

      def user
        @user ||= User.find(params[:id])
      end

      def authorize_user
        return if current_user.id == user.id

        render_error('Unauthorized', :forbidden)
      end
    end
  end
end
