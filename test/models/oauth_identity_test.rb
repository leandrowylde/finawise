require "test_helper"

class OauthIdentityTest < ActiveSupport::TestCase
  test "valid with provider, uid, and user" do
    identity = OauthIdentity.new(provider: "google", uid: "1234567890", user: users(:one))
    assert identity.valid?
  end

  test "invalid without provider" do
    identity = OauthIdentity.new(uid: "1234567890", user: users(:one))
    assert_not identity.valid?
  end

  test "invalid without uid" do
    identity = OauthIdentity.new(provider: "google", user: users(:one))
    assert_not identity.valid?
  end

  test "invalid without user" do
    identity = OauthIdentity.new(provider: "google", uid: "1234567890")
    assert_not identity.valid?
  end

  test "provider and uid are unique together" do
    existing = oauth_identities(:one)
    duplicate = OauthIdentity.new(provider: existing.provider, uid: existing.uid, user: users(:two))
    assert_not duplicate.valid?
  end

  test "belongs to a user" do
    identity = oauth_identities(:one)
    assert_instance_of User, identity.user
  end

  test "find or create from google auth hash" do
    auth = {
      "provider" => "google",
      "uid" => "google-unique-uid-999",
      "info" => { "email" => "newuser@gmail.com" }
    }
    assert_difference "User.count", 1 do
      assert_difference "OauthIdentity.count", 1 do
        user = OauthIdentity.find_or_create_from_auth(auth)
        assert_equal "newuser@gmail.com", user.email_address
      end
    end
  end

  test "find_or_create_from_auth returns existing user if identity exists" do
    existing_identity = oauth_identities(:one)
    auth = {
      "provider" => existing_identity.provider,
      "uid" => existing_identity.uid,
      "info" => { "email" => existing_identity.user.email_address }
    }
    assert_no_difference "User.count" do
      user = OauthIdentity.find_or_create_from_auth(auth)
      assert_equal existing_identity.user, user
    end
  end
end
