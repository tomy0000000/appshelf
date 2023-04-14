# frozen_string_literal: true

system 'pnpm install' if Rails.env.development? || Rails.env.test?
