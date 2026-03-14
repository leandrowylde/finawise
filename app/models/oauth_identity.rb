class OauthIdentity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }

  def self.find_or_create_from_auth(auth)
    identity = find_by(provider: auth["provider"], uid: auth["uid"])
    return identity.user if identity

    transaction do
      user = User.find_or_create_by!(email_address: auth.dig("info", "email")) do |u|
        u.password = SecureRandom.hex(24)
      end
      create!(provider: auth["provider"], uid: auth["uid"], user: user)
      user
    end
  end
end
