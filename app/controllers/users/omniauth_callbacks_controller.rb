require 'spotify_client'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  

  def spotify
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    access_token = request.env["omniauth.auth"].credentials["token"]
    session[:access_token] = access_token

    spotify_client = Spotify::Client.new(:access_token => access_token, retries: 0, raise_errors: true)
    @spotify_client = spotify_client

    @spotify_id = spotify_client.me["id"]
    write_user_top_tracks
    binding.pry

    if @user.persisted?
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

  # normal end of 

  def write_user_top_tracks 

    TopTrack.destroy_by(user_id: @user.id)

    for timeframe in ['short_term', 'medium_term', 'long_term'] do
      for track in top_tracks(timeframe) do
        t = TopTrack.new
        t.artist = track[:artist]
        t.album = track[:album]
        t.track = track[:track]
        t.popularity = track[:popularity]
        t.timeframe = timeframe
        t.user_id = @user.id
        t.track_id = track[:id]
        track_features = track_audio_features(track[:id])
        t.acousticness = track_features['acousticness']
        t.danceability = track_features['danceability']
        t.energy = track_features['energy']
        t.instrumentalness = track_features['instrumentalness']
        t.valence = track_features['valence']
        t.tempo = track_features['tempo']
        t.save
      end
    end

    # binding.pry
  end

  def top_tracks(term)
    @spotify_client
      .me_top_tracks(time_range: term, limit: 5)["items"]
      .map{ |item| {
        artist: item["album"]["artists"].first["name"],
        album: item["album"]["name"],
        track: item["name"],
        popularity: item["popularity"],
        id: item["id"]
        }
      }
      .sort_by{ |hsh| hsh[:popularity]}
  end

  def track_audio_features(track_id)
    @spotify_client.track_audio_features(track_id)
  end

end

