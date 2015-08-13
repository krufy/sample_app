class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token

  has_secure_password

  validates :name, :email, presence: true
  validates :name, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}, allow_blank: true

  before_save do
    self.email = email.downcase
  end

  before_create :create_activation_digest

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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # 忘记持久登入
  def forget
    update_attribute(:remember_digest, nil)
  end

  # 是否是管理员
  def admin?
    admin
  end

  # 是否激活
  def activated?
    activated
  end

  # 发送激活邮件
  def send_activation_email
    UserMailer.account_activate(self).deliver_now
  end

  # 激活用户
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 生成密码重置摘要
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(self.reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # 发送密码重置密码
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # 重置摘要是否过期
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private
    def create_activation_digest
      self.activation_token =  User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
