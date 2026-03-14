require "test_helper"

class OauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:google_oauth2)
  end

  test "creates session for existing oauth identity" do
    identity = oauth_identities(:one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: identity.provider,
      uid: identity.uid,
      info: { email: identity.user.email_address }
    )

    get "/auth/google_oauth2/callback"
    assert_redirected_to root_path
  end

  test "creates new user and session for new oauth identity" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google",
      uid: "brand-new-uid-999",
      info: { email: "brandnewuser@gmail.com" }
    )

    assert_difference [ "User.count", "OauthIdentity.count" ], 1 do
      get "/auth/google_oauth2/callback"
    end
    assert_redirected_to root_path
  end

  test "redirects to login on failure" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
    get "/auth/failure", params: { message: "invalid_credentials" }
    assert_redirected_to new_session_path
  end
end
