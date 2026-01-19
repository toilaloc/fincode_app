# frozen_string_literal: true

class Refund < ApplicationRecord
  belongs_to :payment
  belongs_to :processed_by, class_name: 'User', optional: true
  
  enum status: {
    pending: 'pending',
    completed: 'completed',
    failed: 'failed'
  }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  
  validate :amount_does_not_exceed_refundable_amount, on: :create
  
  scope :completed, -> { where(status: :completed) }
  scope :pending, -> { where(status: :pending) }
  scope :for_payment, ->(payment_id) { where(payment_id: payment_id) }
  
  private
  
  def amount_does_not_exceed_refundable_amount
    return unless payment && amount
    
    refundable = payment.refundable_amount
    if amount > refundable
      errors.add(:amount, "exceeds refundable amount (¥#{refundable})")
    end
  end
end
