# frozen_string_literal: true

json.extract! entry, :id, :app_id, :list_id, :created_at, :updated_at
json.url entry_url(entry, format: :json)
