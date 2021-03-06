class Address < ActiveRecord::Base
  validates_presence_of :full_name, :email_address, :address_line_1, :town_city, :postcode, :country_id
  validates_format_of :email_address, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  belongs_to :country
  belongs_to :user

  before_validation :set_default_label

  def set_default_label
    self.label = "#{full_name} - #{postcode}" if label.blank?
  end

  def to_s
    label
  end
end
