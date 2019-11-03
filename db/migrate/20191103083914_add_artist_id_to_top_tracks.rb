class AddArtistIdToTopTracks < ActiveRecord::Migration[6.0]
  def change
    add_column :top_tracks, :artist_id, :string
  end
end
