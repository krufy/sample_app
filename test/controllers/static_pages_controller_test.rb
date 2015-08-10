require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  setup do
    @base_title = 'Ruby on Rails Tutorial Sample App'
  end

  test "should get home" do
    get :home
    assert_response :success
    assert_select 'title', full_title('Home')
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select 'title', full_title('Help')
  end

  test "should get about" do
    get :about
    assert_response :success
    assert_select 'title', full_title('About')
  end

  test "should get contact" do
    get :contact
    assert_response :success
    assert_select 'title', full_title('Contact')
  end

  test "name should not be too long" do
    @user.name = 'a' * 51
    assert_not user.valid?
  end

  test "email should not be too long" do
    @user.name = 'a' * 244 + '@example.com'
    assert_not user.valid?
  end

end
