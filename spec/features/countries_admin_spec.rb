require 'spec_helper'

feature 'Countries admin' do
  fixtures :websites

  background do
    sign_in_as_admin
  end

  let(:country) { FactoryGirl.build(:country, website: websites(:guitar_gear)) }

  scenario 'Create country' do
    visit admin_countries_path
    click_link 'New'
    fill_in 'Name', with: country.name
    fill_in 'ISO 3166-1 alpha-2', with: country.iso_3166_1_alpha_2
    puts country.iso_3166_1_alpha_2
    click_button 'Create Country'
    expect(Country.find_by(name: country.name)).to be
  end

  scenario 'Edit country' do
    country.save
    visit admin_countries_path
    click_link "Edit #{country}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Update Country'
    expect(Country.find_by(name: new_name)).to be
  end

  scenario 'Delete country' do
    country.save
    visit admin_countries_path
    click_link "Delete #{country}"
    expect(Country.find_by(name: country.name)).to be_nil
  end
end