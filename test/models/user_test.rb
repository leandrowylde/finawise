require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal "downcased@example.com", user.email_address
  end

  test "valid user with email and password" do
    user = User.new(email_address: "alice@example.com", password: "secret123", password_confirmation: "secret123")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(password: "secret123")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "invalid with duplicate email" do
    user = User.new(email_address: users(:one).email_address, password: "secret123")
    assert_not user.valid?
  end

  test "authenticates with correct password" do
    assert users(:one).authenticate("password")
  end

  test "does not authenticate with wrong password" do
    assert_not users(:one).authenticate("wrongpassword")
  end

  test "has many sessions destroyed on delete" do
    user = users(:one)
    user.sessions.create!
    assert_difference "Session.count", -user.sessions.count do
      user.destroy
    end
  end
end
