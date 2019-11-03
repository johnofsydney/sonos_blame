class CreateTopArtists < ActiveRecord::Migration[6.0]
  def change
    create_table :top_artists do |t|
      t.string :artist
      t.string :artist_id
      t.string :timeframe

      t.references :user, null: false, foreign_key: true
    end
  end
end
