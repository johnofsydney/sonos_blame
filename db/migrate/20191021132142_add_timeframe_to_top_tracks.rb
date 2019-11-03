class AddTimeframeToTopTracks < ActiveRecord::Migration[6.0]
  def change
    add_column :top_tracks, :timeframe, :string
  end
end
