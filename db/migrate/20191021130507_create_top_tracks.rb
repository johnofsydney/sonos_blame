class CreateTopTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :top_tracks do |t|
      t.string :artist
      t.string :album
      t.string :track
      t.integer :popularity

      t.timestamps
    end
  end
end
