class User < ActiveRecord::Base
  has_secure_password

  validates :name, :email, presence: true
  validates :name, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}

  before_save do
    self.email = email.downcase
  end

end
