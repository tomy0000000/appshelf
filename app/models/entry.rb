# frozen_string_literal: true

class Entry
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :app
  belongs_to :list
end
