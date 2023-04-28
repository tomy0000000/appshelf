# frozen_string_literal: true

class List
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  has_many :entries, dependent: :destroy
  has_many :apps, dependent: nil
  belongs_to :user

  validates :name, presence: true
  validates_associated :entries
end
