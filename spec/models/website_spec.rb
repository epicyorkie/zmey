require 'spec_helper'

describe Website do 
  before(:each) do
    @website = Website.new(
      :subdomain => 'bonsai',
      :domain => 'www.artofbonsai.com',
      :name => 'Art of Bonsai',
      :email => 'artofbonsai@example.org',
      :google_analytics_code => 'UA-9999999-9',
      country: FactoryGirl.create(:country))
  end

  describe 'validations that need an existing record' do
    before do
      @website.save
    end

    it { should validate_uniqueness_of :google_analytics_code }
  end

  it { should validate_presence_of :name }

  describe "validations" do
    it "should be valid with valid attributes" do
      expect(@website).to be_valid
    end

    it "should require a worldpay_installation_id and worldpay_payment_response_password when active" do
      @website.worldpay_active = true
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = '1234'
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = ''
      @website.worldpay_payment_response_password = 'abcde'
      expect(@website).to_not be_valid

      @website.worldpay_installation_id = '1234'
      @website.worldpay_payment_response_password = 'abcde'
      expect(@website).to be_valid
    end
  end

  it "should only accept payment on account when payment on account is accepted and no other payment methods are" do
    @website.accept_payment_on_account = true
    @website.worldpay_active = false
    expect(@website.only_accept_payment_on_account?).to be_true

    @website.worldpay_active = true
    expect(@website.only_accept_payment_on_account?).to be_false

    @website.accept_payment_on_account = false
    @website.worldpay_active = false
    expect(@website.only_accept_payment_on_account?).to be_false
  end

  it 'orders enquiries in reverse chronological order' do
    @website.save

    params = {name: 'Alice', telephone: '123', email: 'alice@example.org', enquiry: 'Hello'}

    enquiries = []
    enquiries << Enquiry.create!(params)
    enquiries << Enquiry.create!(params)
    enquiries << Enquiry.create!(params)

    [ 1.hour.ago, 5.minutes.ago, 1.minute.ago ].each_with_index do |time, index|
      enquiry = enquiries[index]
      enquiry.created_at = time
      enquiry.website_id = @website.id
      enquiry.save!
    end

    expect(@website.enquiries.first).to eq enquiries.last
    expect(@website.enquiries.second).to eq enquiries.second
    expect(@website.enquiries.third).to eq enquiries.first
  end

  describe '#populate_countries!' do
    it 'should populate itself with a number of countries' do
      @website.save
      @website.populate_countries!
      expect(@website.countries).to have(248).countries
    end
  end

  describe '#image_uploader' do
    let(:params)   { { image: fixture_file_upload('images/red.png'), name: 'Red' } }
    let(:website)  { Website.new }
    let(:uploader) { website.image_uploader(params) }

    it 'returns an ImageUploader' do
      expect(uploader).to be_instance_of ImageUploader
    end

    it 'associates the image with the itself' do
      image = FactoryGirl.create(:image)
      Image.stub(:new).and_return(image)
      uploader
      expect(image.website).to eq website
    end

    it 'yields the image' do
      image = nil
      website.image_uploader(params) do |yielded|
        image = yielded
      end
      expect(image).to be_instance_of Image
    end
  end
end
