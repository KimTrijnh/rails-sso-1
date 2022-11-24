class OmniauthController < ActionController::Base
  def new
    render :new
  end

  def endsession
    reset_session
    redirect_to 'http://eh.local:3000/users/sign_out'
  end

  def callback
    auth_info = request.env['omniauth.auth']
    session["idp_access_token"] = auth_info["credentials"]["token"]
    session["idp_expires_at"] = auth_info["credentials"]["expires_at"]
    session["idp_user_email"] = auth_info["info"]["email"]

    redirect_to root_path
  end
end
