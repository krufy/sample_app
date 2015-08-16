require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = users(:mike)
    @micropost = @user.microposts.build(content: 'Lorem ipsum')
  end

  test 'should be valid' do
    assert @micropost.valid?
  end

  test 'should not be valid' do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test 'content should be present' do
    @micropost.content = ''
    assert @micropost.invalid?
  end

  test 'content length should not greater than 140' do
    assert @micropost.valid?
    @micropost.content = 'a' * 141
    assert @micropost.invalid?
  end

  test 'order should be most recent first' do
    assert_equal Micropost.first, microposts(:most_recent)
  end
end
