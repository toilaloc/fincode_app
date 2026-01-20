# frozen_string_literal: true

module Api
  module V1
    class MagicLinksController < ApplicationController
      skip_before_action :authenticate_request, :authenticate_user!, only: %i[request_magic_link verify]
      before_action :check_email, only: [:request_magic_link]

      def request_magic_link
        magic_link_service = MagicLinkService.new
        magic_link_result = magic_link_service.generate_magic_token(email: user.email)

        MagicLinkMailer.magic_link_email(user:, magic_token: magic_link_result[:magic_token]).deliver_later

        render json: {
          message: 'Magic link has been sent to your email',
          email: user.email,
          expires_in: '60 minutes'
        }, status: :ok
      end

      def verify
        magic_link_service = MagicLinkService.new
        result = magic_link_service.verify_magic_token_and_create_access_token(email: user.email,
                                                                               magic_token: params[:token])

        render json: {
          message: 'Successfully logged in',
          user: Api::V1::UserSerializer.new(result[:user]).as_json,
          access_token: result[:access_token],
          expires_in: result[:expires_in]
        }, status: :ok
      end

      def extend; end

      def logout
        magic_link_service = MagicLinkService.new(session:)
        magic_link_service.logout

        render_success(:logged_out)
      end

      private

      def user
        @user ||= User.find_by(email: params[:email])
      end

      def check_email
        return if user.present?

        render json: { error: 'Email not found in our system' }, status: :not_found
      end
    end
  end
end
