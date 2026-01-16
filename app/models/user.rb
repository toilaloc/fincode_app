# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :payments
  has_many :products
  has_many :orders

  validates :display_name, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_digest_changed?
  validates :password_confirmation, presence: true, if: :password_digest_changed?
end
