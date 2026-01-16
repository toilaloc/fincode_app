module Api
  module V1
    class HealthController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false
      skip_before_action :authenticate_request, raise: false
      skip_before_action :authenticate_user!, raise: false

      def show
        ActiveRecord::Base.connection.execute("SELECT 1")
        
        redis = REDIS_CLIENT
        redis.ping

        version = begin
          Rails.application.config.version
        rescue
          'unknown'
        end

        render json: {
          status: 'ok',
          service: 'kakeibo-api',
          timestamp: Time.current.iso8601,
          version: version,
          environment: Rails.env
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Health check failed: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        
        render json: {
          status: 'error',
          error: e.message,
          timestamp: Time.current.iso8601
        }, status: :service_unavailable
      end
    end
  end
end
