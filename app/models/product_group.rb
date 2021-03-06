class ProductGroup < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :website_id

  has_many :product_group_placements, dependent: :delete_all
  has_many :products, through: :product_group_placements

  def to_s
    name
  end
end
