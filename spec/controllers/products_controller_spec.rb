require 'spec_helper'
require 'shared_examples_for_controllers'

describe ProductsController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_product(stubs={})
    @mock_product ||= mock_model(Product, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
    website.stub(:vat_number).and_return('')
  end

  describe "GET show" do
    context 'when product active' do
      before do
        find_requested_product(
          :active? => true, page_title: '', name: '', meta_description: ''
        )
      end

      it "assigns the requested product as @product" do
        get :show, id: '37'
        expect(assigns[:product]).to equal(mock_product)
      end
    end

    context 'when product inactive' do
      before do
        find_requested_product(
          :active? => false, page_title: '', name: '', meta_description: ''
        )
      end

      context 'as admin' do
        before { logged_in_as_admin }

        it 'succeeds' do
          get :show, id: '37'
          expect(response).to be_successful
        end
      end

      context 'as visitor' do
        it '404s' do
          get :show, id: '37'
          expect(response.status).to eq 404
        end
      end
    end
  end

  def find_requested_product(stubs={})
    Product.should_receive(:find_by).with(id: '37', website_id: website.id).and_return(mock_product(stubs))
  end
end
