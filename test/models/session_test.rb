require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "belongs to a user" do
    session = sessions(:one)
    assert_instance_of User, session.user
  end

  test "is destroyed when user is destroyed" do
    user = users(:one)
    session_id = sessions(:one).id
    user.destroy
    assert_nil Session.find_by(id: session_id)
  end
end
