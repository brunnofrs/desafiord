class ManageAbandonedCartsJob < ApplicationJob
    queue_as :default
  
    def perform
      mark_abandoned_carts
      remove_old_abandoned_carts
    end
  
    private
  
  
    def mark_abandoned_carts
      abandonment_threshold = 3.hours.ago
      carts_to_mark = Cart.where(abandoned_at: nil).where('updated_at < ?', abandonment_threshold)
      carts_to_mark.update_all(abandoned_at: Time.current)
    end
  
    def remove_old_abandoned_carts
      removal_threshold = 7.days.ago
      Cart.where('abandoned_at < ?', removal_threshold).destroy_all
    end
  end