# frozen_string_literal: true

class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, and :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]

  ## Database authenticatable
  field :email,              type: String, default: ''
  field :username,           type: String, default: ''
  field :encrypted_password, type: String, default: ''
  index({ username: 1 }, { unique: true, name: 'username_index' })

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  # field :sign_in_count,      type: Integer, default: 0
  # field :current_sign_in_at, type: Time
  # field :last_sign_in_at,    type: Time
  # field :current_sign_in_ip, type: String
  # field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  field :google_uid, type: String

  field :public, type: Boolean, default: false
  has_many :lists, dependent: :destroy

  # Change login from email to username
  validates :username, uniqueness: true

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end

  def self.find_where_google(google_params)
    User.where(google_uid: google_params[:uid]).first
  end

  def self.new_from_google(google_params)
    existed = User.where(username: google_params[:name]).first
    username = existed ? "#{google_params[:name]}#{rand(1000)}" : google_params[:name]
    User.create!(google_uid: google_params[:uid], username:, password: Devise.friendly_token[0, 20])
  end

  include Mongoid::Timestamps
end
