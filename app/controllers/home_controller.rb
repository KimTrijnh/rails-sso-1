class HomeController < ApplicationController
  def index
    @user = session["idp_user_email"]
    render 'index'
  end
end
