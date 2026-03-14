class OauthCallbacksController < ApplicationController
  allow_unauthenticated_access only: %i[ create failure ]

  def create
    user = OauthIdentity.find_or_create_from_auth(request.env["omniauth.auth"])
    start_new_session_for user
    redirect_to after_authentication_url, notice: "Signed in successfully."
  rescue => e
    Rails.logger.error "OAuth error: #{e.message}"
    redirect_to new_session_path, alert: "Sign-in failed. Please try again."
  end

  def failure
    redirect_to new_session_path, alert: "OAuth sign-in failed: #{params[:message]}"
  end
end
