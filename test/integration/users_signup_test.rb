require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "invalid sign up" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: {name: "",
                              email: 'user@invalid',
                              password: "foo",
                              password_field: "bar"}
    end
    assert_template "users/new"
  end

  test "valid sign up" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: {name: 'mike',
                              email: 'mike@example.com',
                              password: 'mike1234',
                              password_confirmation: 'mike1234'}
    end
    assert_template 'users/show'
  end
end
