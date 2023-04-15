# frozen_string_literal: true

class App
  include Mongoid::Document
  include Mongoid::Timestamps
  field :id, type: String
  field :name, type: String
  field :description, type: String
  field :artwork, type: String
  belongs_to :list
end
