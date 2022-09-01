class List
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String

  has_many :apps, dependent: :destroy
end
