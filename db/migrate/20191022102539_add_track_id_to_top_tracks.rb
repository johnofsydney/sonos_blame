class AddTrackIdToTopTracks < ActiveRecord::Migration[6.0]
  def change
    add_column :top_tracks, :track_id, :string
    add_column :top_tracks, :mode, :integer
    add_column :top_tracks, :time_signature, :integer
    add_column :top_tracks, :acousticness, :float
    add_column :top_tracks, :danceability, :float
    add_column :top_tracks, :energy, :float
    add_column :top_tracks, :instrumentalness, :float
    add_column :top_tracks, :valence, :float
    add_column :top_tracks, :tempo, :float
  end
end
