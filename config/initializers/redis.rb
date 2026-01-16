# frozen_string_literal: true

require 'redis'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
uri = URI.parse(redis_url)

redis_config = {
  url: redis_url,
  timeout: 5,
  reconnect_attempts: 3
}

redis_config[:password] = uri.password if uri.password

begin
  REDIS_CLIENT = Redis.new(redis_config)
  REDIS_CLIENT.ping
  Rails.logger.info "Redis connected successfully at #{uri.host}:#{uri.port}"
rescue Redis::CannotConnectError => e
  Rails.logger.error "Redis connection failed: #{e.message}"
  raise
rescue StandardError => e
  Rails.logger.error "Redis error: #{e.class} - #{e.message}"
  raise
end
