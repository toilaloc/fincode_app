# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :products

  validates :name, uniqueness: { case_sensitive: false }, presence: true
end
