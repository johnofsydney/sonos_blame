require 'spotify_client'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  

  def spotify
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    access_token = request.env["omniauth.auth"].credentials["token"]
    session[:access_token] = access_token

    if @user.persisted?

      SpotifyAddUserDataWorker.perform_async(@user.id, access_token)
      flash[:notice] = "Pokemons getting added to db"


      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      
      set_flash_message(:notice, :success, kind: "Spotify") if is_navigational_format?
    else
      session["devise.spotify_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def github
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Github") if is_navigational_format?
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end

