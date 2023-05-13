# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user = User.from_google(from_google_params)

    if user.present?
      sign_out_all_scopes
      flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      flash[:alert] =
        t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: 'User is not authorized.'
      redirect_to new_user_session_path
    end
  end

  private

  # this is a before_action for google_oauth2
  def from_google_params
    @from_google_params ||= {
      uid: auth.uid,
      name: auth.info.name,
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      image: auth.info.image
    }
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
