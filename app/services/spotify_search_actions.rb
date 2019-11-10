require_relative '../../lib/constants'
require 'pry-byebug'
require 'spotify_client'

class SpotifySearchActions
  include Constants

  def initialize(user, access_token)
    @user = user
    @spotify_client = Spotify::Client.new(:access_token => access_token, retries: 0, raise_errors: true)
  end

  def search_artist(band_name)
    @spotify_client.search(:artist, band_name)
  end

  # def related_artists(artist_id)
  def related_artists(artist_id)
    @spotify_client.related_artists(artist_id)
  end
end



