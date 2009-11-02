class Basket < ActiveRecord::Base
  # basket items are destroyed so that their feature selections can be cleaned up
  has_many :basket_items, :dependent => :destroy
  def total
    total = 0.0
    basket_items.each {|i| total += i.line_total}
    total
  end
  
  def self.purge_old(age = 1.month)
    self.destroy_all(["created_at < ?", Time.now - age])
  end
end