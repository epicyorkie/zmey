class AddFeatureDescriptionsToOrderLines < ActiveRecord::Migration
  def self.up
    add_column :order_lines, :feature_descriptions, :text
  end

  def self.down
    remove_column :order_lines, :feature_descriptions
  end
end
