# frozen_string_literal: true

class App
  include Mongoid::Document
  include Mongoid::Timestamps
  field :id, type: String
  field :name, type: String
  field :description, type: String
  field :artwork, type: String
  has_many :entries, dependent: :destroy
  has_many :lists, dependent: nil

  # validates :id, presence: true
end
