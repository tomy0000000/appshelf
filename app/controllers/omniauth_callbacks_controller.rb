# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user = User.find_where_google(google_params)

    if user.present?
      flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      if user_signed_in?
        current_user.update(google_uid: google_params[:uid])
        flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
        redirect_to edit_user_path current_user.username
        return
      end

      User.new_from_google(google_params)
      flash[:alert] =
        t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: 'User is not authorized.'
      redirect_to new_user_session_path
    end
  end

  private

  # this is a before_action for google_oauth2
  def google_params
    @google_params ||= {
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
