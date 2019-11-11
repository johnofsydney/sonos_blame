require 'spotify_client'

require_relative '../services/spotify_database_actions'

# Worker to add data for this spotify user
class SpotifyAddUserDataWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, access_token)
    @user = User.find_by(id: user_id)
    @spotify_client = Spotify::Client.new(:access_token => access_token, retries: 0, raise_errors: true)

    # if the browser is closed but the sidekiqserver is still running
    # a new instance is NOT instantiated
    # when the browser is re-opened and login to app
    actions = SpotifyDatabaseActions.new(@user, @spotify_client)
    # but these methods still run ok
    actions.write_user_top_tracks
    actions.write_user_top_artists
    actions.add_scores_to_artists
  end
end
