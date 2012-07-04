class Product < ActiveRecord::Base
  attr_accessible :apply_shipping, :availability, :brand, :condition, :description,
    :full_detail, :gtin, :google_product_category, :google_title, :image_id,
    :meta_description, :mpn, :name, :page_title, :price, :product_type, :shipping_supplement,
    :sku, :submit_to_google, :tax_type, :weight

  validates_presence_of :name, :sku
  validates_uniqueness_of :sku, :scope => :website_id

  CONDITIONS = %w[new used refurbished]
  validates_inclusion_of :condition, in: CONDITIONS
  AVAILABILITIES = ['in stock', 'available for order', 'out of stock', 'preorder']
  validates_inclusion_of :availability, in: AVAILABILITIES

  has_many :product_placements, :dependent => :delete_all
  has_many :additional_products, :dependent => :delete_all
  has_many :pages, :through => :product_placements
  has_many :components, dependent: :destroy
  has_many :features, :dependent => :destroy
  has_many :quantity_prices, :order => :quantity, :dependent => :delete_all
  belongs_to :image
  belongs_to :website
  has_many :product_group_placements, :dependent => :delete_all
  has_many :product_groups, :through => :product_group_placements
  has_many :basket_items, dependent: :destroy

  liquid_methods :id, :description, :full_detail, :name, :path, :shipping_supplement, :sku, :url

  # Tax types
  NO_TAX = 1
  INC_VAT = 2
  EX_VAT = 3

  VAT_RATE = 0.2

  def name_with_sku
    name + ' [' + sku + ']'
  end
  
  # the price of a single product when quantity q is purchased as entered
  # by the merchant -- tax is not considered
  def price_at_quantity(q)
    p = price
    if q > 1 and !quantity_prices.empty?
      quantity_prices.each {|qp| p = qp.price if q >= qp.quantity}
    end
    p
  end

  # the amount of tax for a single product when quantity q is purchased
  def tax_amount(q=1)
    if tax_type == Product::EX_VAT
      price_at_quantity(q) * Product::VAT_RATE
    elsif tax_type == Product::INC_VAT
      price_at_quantity(q) - price_ex_tax(q)
    else
      0
    end
  end
  
  # the price exclusive of tax for a single product when quantity q is purchased
  def price_ex_tax(q=1)
    if tax_type == Product::INC_VAT
      price_at_quantity(q) / (Product::VAT_RATE + 1)
    else
      price_at_quantity(q)
    end
  end

  # the price inclusive of tax for a single product when quantity q is purchased
  def price_inc_tax(q=1)
    if tax_type == Product::EX_VAT
      price_at_quantity(q) + tax_amount(q)
    else
      price_at_quantity(q)
    end
  end

  # the price for a single product when quantity q is purchased with tax included
  # if inc_tax is true or tax excluded if inc_tax is false
  def price_with_tax(q, inc_tax)
    if inc_tax
      price_inc_tax(q)
    else
      price_ex_tax(q)
    end
  end

  def path
    '/products/' + to_param
  end

  def url
    'http://' + website.domain + path
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def self.delete_all
    destroy_all
  end

  def delete
    destroy
  end
end
