# frozen_string_literal: true

require 'application_system_test_case'

class AppsTest < ApplicationSystemTestCase
  setup do
    @app = apps(:one)
  end

  test 'visiting the index' do
    visit apps_url
    assert_selector 'h1', text: 'Apps'
  end

  test 'should create app' do
    visit apps_url
    click_on 'New app'

    fill_in 'Description', with: @app.description
    fill_in 'Id', with: @app.id
    fill_in 'List', with: @app.list_id
    fill_in 'Name', with: @app.name
    click_on 'Create App'

    assert_text 'App was successfully created'
    click_on 'Back'
  end

  test 'should update App' do
    visit app_url(@app)
    click_on 'Edit this app', match: :first

    fill_in 'Description', with: @app.description
    fill_in 'Id', with: @app.id
    fill_in 'List', with: @app.list_id
    fill_in 'Name', with: @app.name
    click_on 'Update App'

    assert_text 'App was successfully updated'
    click_on 'Back'
  end

  test 'should destroy App' do
    visit app_url(@app)
    click_on 'Destroy this app', match: :first

    assert_text 'App was successfully destroyed'
  end
end
