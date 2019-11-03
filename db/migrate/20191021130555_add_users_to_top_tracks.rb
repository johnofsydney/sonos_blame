class AddUsersToTopTracks < ActiveRecord::Migration[6.0]
  def change
    add_reference :top_tracks, :user, null: false, foreign_key: true
  end
end
