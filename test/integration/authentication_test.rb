require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "sign in with valid credentials creates session and redirects" do
    user = users(:one)
    post session_path, params: { email_address: user.email_address, password: "password" }
    assert_redirected_to root_path
  end

  test "sign in with invalid credentials redirects back to login with alert" do
    post session_path, params: { email_address: "nobody@example.com", password: "wrong" }
    assert_redirected_to new_session_path
  end

  test "sign out destroys session and redirects to login" do
    user = users(:one)
    post session_path, params: { email_address: user.email_address, password: "password" }
    delete session_path
    assert_redirected_to new_session_path
  end

  test "protected page redirects unauthenticated user to login" do
    get root_path
    assert_redirected_to new_session_path
  end
end
