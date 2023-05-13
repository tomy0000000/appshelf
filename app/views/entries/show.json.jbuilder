# frozen_string_literal: true

json.extract! @entry, :app, :list, :created_at, :updated_at
json.url entry_url(@entry, format: :json)
