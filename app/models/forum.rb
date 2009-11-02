class Forum < ActiveRecord::Base
  belongs_to :website
  has_many :topics, :order => 'created_at DESC'
  validates_uniqueness_of :name, :scope => :website_id, :case_sensitive => false
end