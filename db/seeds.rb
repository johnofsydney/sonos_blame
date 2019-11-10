# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'

TopTrack.destroy_all
TopArtist.destroy_all
User.destroy_all

1.times do
  u = User.new
  u.email = Faker::Internet.email
  u.password = 'chicken'
  u.password_confirmation = 'chicken'
  u.name = Faker::Name.name
  u.save!
  5.times do
    t = TopTrack.new
    t.track_id = Faker::Internet.password
    t.artist = Faker::Music.band
    t.album = Faker::Music.album
    t.track = Faker::Music.song
    t.popularity = (0..99).to_a.shuffle.take(1).first
    t.timeframe = ['short_term', 'medium_term', 'long_term'].shuffle.take(1).first
    t.user_id = u.id
    t.track_id = Faker::Music.spotify_track_id
    t.artist_id = Faker::Music.spotify_artist_id
    t.save
  end
  5.times do
    t = TopArtist.new
    t.artist = Faker::Music.band
    t.artist_id = Faker::Music.spotify_artist_id
    t.timeframe = ['short_term', 'medium_term', 'long_term'].shuffle.take(1).first
    t.user_id = u.id
    t.score = (0..49).to_a.shuffle.take(1).first
    t.save
  end
end