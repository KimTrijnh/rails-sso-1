class ApplicationController < ActionController::Base
  before_action :authenticate!

  private
  def authenticate!
    unless session["idp_access_token"].present?
      reset_session
    end
  end
end
