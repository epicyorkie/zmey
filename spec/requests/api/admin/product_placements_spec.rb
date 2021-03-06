require 'rails_helper'

describe 'Admin product placements API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    it 'inserts a new product placement' do
      page = FactoryGirl.create(:page, website_id: @website.id)
      product = FactoryGirl.create(:product, website_id: @website.id)
      post '/api/admin/product_placements', product_placement: {page_id: page.id, product_id: product.id}
      expect(ProductPlacement.find_by(page_id: page.id, product_id: product.id)).to be
    end
  end

  describe 'DELETE delete_all' do
    it 'deletes all product placements in the website' do
      product_1 = FactoryGirl.create(:product, website_id: @website.id)
      product_2 = FactoryGirl.create(:product)
      page_1 = FactoryGirl.create(:page, website_id: @website.id)
      page_2 = FactoryGirl.create(:page)
      placement_1 = ProductPlacement.create!(page: page_1, product: product_1)
      placement_2 = ProductPlacement.create!(page: page_2, product: product_2)

      delete '/api/admin/product_placements'

      expect(ProductPlacement.find_by(id: placement_1.id)).not_to be
      expect(ProductPlacement.find_by(id: placement_2.id)).to be
    end

    it 'responds with 204 No Content' do
      delete '/api/admin/product_placements'

      expect(status).to eq 204
    end
  end
end
