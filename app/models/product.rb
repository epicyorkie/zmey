class Product < ActiveRecord::Base
  validates_presence_of :name, :sku
  validates_uniqueness_of :sku, :scope => :website_id
end