# frozen_string_literal: true

class AppLookup < ApplicationService
  attr_reader :name, :country

  def initialize(app_id, country)
    super()
    @app_id = app_id
    @country = country
  end

  def call
    response = Faraday.get('https://itunes.apple.com/lookup', { id: @app_id, country: @country, media: 'software' })
    @body = JSON.parse(response.body)

    return nil if response.status != 200 || @body['resultCount'].zero?

    @body['results'][0]
  end
end
