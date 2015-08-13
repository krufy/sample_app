class PasswordsController < ApplicationController
  before_action :set_user, only: [:create, :edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:email].downcase)
    if @user
      if @user.activated?
        @user.create_reset_digest
        @user.send_password_reset_email
        flash[:info] = '重置链接已经发送你的邮箱'
      else
        flash[:danger] = '邮箱还没有激活'
      end
      redirect_to login_url
    else
      flash.now[:danger]= '邮箱不存在'
      render 'new'
    end
  end

  def edit
  end

  def update
    if password_blank?
      flash.now[:danger] = '密码不能为空'
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = '密码更新成功'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
    def set_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        flash[:danger] = '无效的密码重置链接'
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = '链接已过期'
        redirect_to new_password_url
      end
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def password_blank?
      params[:user][:password].blank?
    end
end
