class AddScoreToTopArtists < ActiveRecord::Migration[6.0]
  def change
    add_column :top_artists, :score, :integer
  end
end
