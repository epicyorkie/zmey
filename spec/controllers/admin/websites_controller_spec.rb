require 'spec_helper'

describe Admin::WebsitesController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    controller.stub(:website).and_return(website)
  end

  def mock_website(stubs={})
    @mock_website ||= mock_model(Website, stubs)
  end

  describe 'POST create' do
    context 'when logged in as an administrator' do
      let(:valid_params) { { 'website' => { 'name' => 'foo' } } }

      before { logged_in_as_admin }

      it "creates a new website with the given params" do
        Page.stub(:bootstrap)
        controller.stub(:create_latest_news)

        Website.should_receive(:new).with(valid_params['website']).and_return(website)
        post 'create', valid_params
      end

      it "should populate the website's countries" do
        controller.stub(:create_latest_news)

        website = mock_website({save: true, id: 1, name: 'foo', :blog_id= => nil})
        Website.stub(:new).and_return(website)
        website.should_receive(:populate_countries!)
        post 'create', valid_params
      end
    end
  end
end
