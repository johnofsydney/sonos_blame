require_relative '../../lib/constants'
require 'pry-byebug'
require 'spotify_client'

class SpotifyPlaylistActions
  include Constants

  def initialize(user, access_token)
    @user = user
    @spotify_client = Spotify::Client.new(:access_token => access_token, retries: 0, raise_errors: true)
    @spotify_user_id = @spotify_client.me['id']
  end

  def get_recommendations_from_artists(seeds)
    @spotify_client.recommendations(seed_artists: seeds, limit: 50)
  end

  def make_playlist(name)
    @spotify_client.create_user_playlist(@spotify_user_id, name, is_public = true)
  end

  def add_tracks_to_playlist(playlist_id, uris)
    # def add_user_tracks_to_playlist(user_id, playlist_id, uris = [], position = nil)
    @spotify_client.add_user_tracks_to_playlist(
      @spotify_user_id, 
      playlist_id, 
      uris
    )
  end
end



