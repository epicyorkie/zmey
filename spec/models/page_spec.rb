require 'spec_helper'

describe Page do
  it { should ensure_length_of(:description).is_at_most(200) }

  it 'allows a dot in the slug' do
    page = FactoryGirl.build(:page)
    page.slug = 'legacy.html'
    expect(page).to be_valid
  end

  it 'allows underscores in the slug' do
    page = FactoryGirl.build(:page)
    page.slug = 'legacy_page'
    expect(page).to be_valid
  end
end
