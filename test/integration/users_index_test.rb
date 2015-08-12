require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @admin = users(:mike)
    @non_admin = users(:jordan)
  end

  test "index include pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a[href=?]', user_path(user), text: 'destroy', method: :delete
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'destroy', count: 0
  end
end
