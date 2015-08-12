class User < ActiveRecord::Base
  attr_accessor :remember_token

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

  # 返回指定字符串的哈希摘要
  def self.digest(str)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
    BCrypt::Password.create(str, cost: cost)
  end

  # 生成令牌环
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 持久会话, 存储记住令牌环摘要
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(self.remember_token))
  end

  # 验证令牌环的有效性
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

end
