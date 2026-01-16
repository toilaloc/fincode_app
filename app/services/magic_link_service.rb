# frozen_string_literal: true

class MagicLinkService < BaseService
  include Rails.application.routes.url_helpers

  REDIS_KEY_PREFIX = 'magic_links:'
  ACCESS_TOKEN_PREFIX = 'access_tokens:'
  USER_TOKEN_PREFIX = 'user_tokens:'

  MAGIC_TOKEN_EXPIRY = 10.minutes
  ACCESS_TOKEN_EXPIRY = 60.minutes

  attr_reader :redis_client

  def initialize(redis_client: REDIS_CLIENT)
    @redis_client = redis_client
  end

  def generate_magic_token(email:)
    magic_token = generate_token

    store_in_redis(
      email,
      {
        magic_token:,
        email:,
        generated_at: Time.current.to_i
      },
      MAGIC_TOKEN_EXPIRY
    )

    { magic_token: }
  end

  def verify_magic_token_and_create_access_token(email:, magic_token:, remember_me: false)
    stored_data = fetch_from_redis(email)

    raise ActionFailed, :expired_token unless stored_data
    raise ActionFailed, :invalid_token unless stored_data['magic_token'] == magic_token

    user = User.find_by(email:)
    raise ActionFailed, :not_found unless user

    access_token = generate_token
    expiry = remember_me ? 7.days : ACCESS_TOKEN_EXPIRY

    store_access_token(user.id, access_token, expiry, remember_me)
    delete_magic_link_data(email)

    {
      user:,
      access_token:,
      expires_in: expiry.to_i
    }
  end

  def verify_and_extend_access_token(access_token)
    raise ActionFailed, :unauthorized unless access_token

    token_data = fetch_access_token_data(access_token)
    raise ActionFailed, :expired_token unless token_data

    user_id = token_data['user_id']
    remember_me = token_data['remember_me']
    expiry = remember_me ? 7.days : ACCESS_TOKEN_EXPIRY

    extend_access_token(user_id, access_token, expiry, remember_me)

    user = User.find_by(id: user_id)
    raise ActionFailed, :not_found unless user

    user
  end

  def logout(access_token)
    return unless access_token

    token_hash = hash_token(access_token)

    token_data = fetch_access_token_data(access_token)
    user_id = token_data['user_id'] if token_data

    @redis_client.del(access_token_key(token_hash))
    @redis_client.del(user_token_key(user_id, token_hash)) if user_id
  end

  def fetch_stored_magic_token(email)
    stored_data = fetch_from_redis(email)
    stored_data ? stored_data['magic_token'] : nil
  end

  # Get all active sessions for user
  def get_user_sessions(user_id)
    pattern = "#{USER_TOKEN_PREFIX}#{user_id}:*"
    keys = @redis_client.keys(pattern)

    keys.map do |key|
      token_hash = key.split(':').last
      data = @redis_client.get(access_token_key(token_hash))
      next unless data

      token_data = JSON.parse(data)
      {
        token_hash: token_hash[0..8], # First 9 chars for display
        last_used_at: Time.at(token_data['last_used_at']),
        ttl: @redis_client.ttl(key)
      }
    end.compact
  end

  private

  def generate_token
    SecureRandom.urlsafe_base64(32)
  end

  def hash_token(token)
    Digest::SHA256.hexdigest(token)
  end

  def redis_key(email)
    "#{REDIS_KEY_PREFIX}#{email}"
  end

  def access_token_key(token_hash)
    "#{ACCESS_TOKEN_PREFIX}#{token_hash}"
  end

  def user_token_key(user_id, token_hash)
    "#{USER_TOKEN_PREFIX}#{user_id}:#{token_hash}"
  end

  def store_in_redis(email, data, expiry)
    Rails.logger.debug "Storing magic token for #{email}: #{data.inspect}"
    @redis_client.setex(redis_key(email), expiry.to_i, data.to_json)
  end

  def fetch_from_redis(email)
    data = @redis_client.get(redis_key(email))
    Rails.logger.debug "Fetching magic token for #{email}, raw data: #{data.inspect}"
    data ? JSON.parse(data) : nil
  rescue JSON::ParserError
    nil
  end

  def delete_magic_link_data(email)
    @redis_client.del(redis_key(email))
  end

  # Access token operations
  def store_access_token(user_id, access_token, expiry, remember_me)
    token_hash = hash_token(access_token)
    token_data = {
      user_id: user_id,
      remember_me: remember_me,
      created_at: Time.current.to_i,
      last_used_at: Time.current.to_i
    }.to_json

    # Store in two places for fast lookup
    # 1. By token hash (for quick verification)
    @redis_client.setex(access_token_key(token_hash), expiry.to_i, token_data)
    # 2. By user_id (for logout all devices)
    @redis_client.setex(user_token_key(user_id, token_hash), expiry.to_i, token_data)
  end

  def fetch_access_token_data(access_token)
    token_hash = hash_token(access_token)
    data = @redis_client.get(access_token_key(token_hash))
    data ? JSON.parse(data) : nil
  rescue JSON::ParserError
    nil
  end

  def extend_access_token(user_id, access_token, expiry, remember_me)
    token_hash = hash_token(access_token)
    token_data = {
      user_id: user_id,
      remember_me: remember_me,
      last_used_at: Time.current.to_i
    }.to_json

    # Reset TTL on both keys
    @redis_client.setex(access_token_key(token_hash), expiry.to_i, token_data)
    @redis_client.setex(user_token_key(user_id, token_hash), expiry.to_i, token_data)
  end
end
