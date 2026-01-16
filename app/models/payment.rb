class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true  # Made optional since controller doesn't always create order
  
  enum status: {
    pending: 'pending',
    authorized: 'authorized', 
    captured: 'captured',
    failed: 'failed',
    cancelled: 'cancelled'  # Added cancelled status
  }
  
  validates :fincode_order_id, presence: true, uniqueness: true
  validates :fincode_access_id, presence: true  # Added validation
  validates :amount, presence: true, numericality: { greater_than: 0 }
  
  # FIX: Added condition to check if order exists
  after_update :update_product_stock, if: -> { 
    saved_change_to_status? && captured? && order.present?
  }
  
  # FIX: Added can_capture? method
  def can_capture?
    authorized? && !captured? && !failed? && !cancelled?
  end

  def can_cancel?
    (pending? || authorized?) && !captured? && !failed? && !cancelled?
  end
  
  private
  
  def update_product_stock
    return unless order&.product
    
    if order.product.stock_quantity >= order.quantity
      order.product.decrement!(:stock_quantity, order.quantity)
    else
      errors.add(:base, 'Insufficient stock')
      raise ActiveRecord::RecordInvalid, self
    end
  end
end
