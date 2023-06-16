# frozen_string_literal: true

class AppIdParser < ApplicationService
  attr_reader :name, :country

  def initialize(app_id)
    super()
    @app_id = app_id
  end

  def call
    uri = URI(@app_id)
    match = uri.path.match(%r{^(?:/?(?<country>\w{2})?/app(?:/.+)?/id)?(?<app_id>\d+)$})

    unless match && !match[:app_id].nil? # Must have app_id
      respond_to do |format|
        format.html do
          redirect_to list_url(List.find(params['entry'][:list_id])),
                      alert: "Invalid App ID or URL: #{app_id}"
        end
        format.json { head :no_content }
      end
      return
    end

    # Default to US if no country code is specified
    [match[:country].nil? ? 'us' : match[:country], match[:app_id]]
  end
end
