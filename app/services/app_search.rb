# frozen_string_literal: true

class AppSearch < ApplicationService
  attr_reader :name, :country

  def initialize(name, country)
    super()
    @name = name
    @country = country
  end

  def call
    response = Faraday.get('https://itunes.apple.com/search', { term: @name, country: @country, media: 'software' })
    @body = JSON.parse(response.body)

    return nil if response.status != 200 || @body['resultCount'].zero?

    @body['results']
  end
end
