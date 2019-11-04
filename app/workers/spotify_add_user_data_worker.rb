require 'spotify_client'
require 'pry-byebug'

class SpotifyAddUserDataWorker
  LIMIT = 50
  TERMS = ['short_term', 'medium_term', 'long_term']
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(user_id, access_token)
    @user = User.find_by(id: user_id)

    @spotify_client = Spotify::Client.new(:access_token => access_token, retries: 0, raise_errors: true)

    @spotify_id = @spotify_client.me["id"]

    write_user_top_tracks
    write_user_top_artists
    add_scores_to_artists
    # binding.pry
  end


   def write_user_top_tracks 

    TopTrack.destroy_by(user_id: @user.id)

    for timeframe in TERMS do
      for track in top_tracks(timeframe) do
        # every track gets created as a record in the db
        t = TopTrack.new
        t.artist = track[:artist]
        t.artist_id = track[:artist_id]
        t.album = track[:album]
        t.track = track[:track]
        t.popularity = track[:popularity]
        t.timeframe = timeframe
        t.user_id = @user.id
        t.track_id = track[:id]
        t.save
      end
    end
  end

  def top_tracks(term)
    @spotify_client
      .me_top_tracks(time_range: term, limit: LIMIT)["items"]
      .map{ |item| {
        artist: item["album"]["artists"].first["name"],
        artist_id: item["album"]["artists"].first["id"],
        album: item["album"]["name"],
        track: item["name"],
        popularity: item["popularity"],
        id: item["id"]
        }
      }
      .sort_by{ |hsh| hsh[:popularity] }
      .reject{ |hsh| hsh[:artist] == 'Various Artists' }
  end

  def track_audio_features(track_id)
    @spotify_client.track_audio_features(track_id)
  end

  def write_user_top_artists
    TopArtist.destroy_by(user_id: @user.id)

    for timeframe in TERMS do
      for artist in top_artists(timeframe) do
        # don't create a new artist if that artist already exists in the db
        existing_artist = @user.top_artists.find_by(artist_id: artist[:artist_id])

        add_or_modify_artist(existing_artist, timeframe, artist)
      end
    end
  end

  def add_or_modify_artist(existing_artist, timeframe, artist)
    if existing_artist
      existing_artist[:score] = existing_artist[:score] + artist_timeframe_score(timeframe)
      existing_artist[:timeframe] = 'multiple'
      existing_artist.save
    else
      t = TopArtist.new
      t.artist = artist[:artist]
      t.timeframe = timeframe
      t.user_id = @user.id
      t.artist_id = artist[:artist_id]
      t.score = artist_timeframe_score(timeframe)
      t.save
    end
  end

  def artist_timeframe_score(timeframe)
    return 8 if timeframe == 'long_term'
    return 6 if timeframe == 'medium_term'
    return 3 if timeframe == 'short_term'
    return 0
  end

  def top_artists(term)
    @spotify_client
      .me_top_artists(time_range: term, limit: LIMIT)["items"]
      .map{ |item| {
        artist: item["name"],
        artist_id: item['id']
      }
    }.reject{ |hsh| hsh[:artist] == 'Various Artists' }
  end

  def add_scores_to_artists
    for track in @user.top_tracks do
      artist = @user.top_artists.find_by(artist_id: track[:artist_id])
      if artist
        artist[:score] = artist[:score] + artist_score_from_track(track[:timeframe])
        artist.save
      else
        t = TopArtist.new
        t.artist = track[:artist]
        t.timeframe = track[:timeframe]
        t.user_id = @user.id
        t.artist_id = track[:artist_id]
        t.score = artist_score_from_track(track[:timeframe])
        t.save
      end
    end
  end

  def artist_score_from_track(timeframe)
    return 3 if timeframe == 'long_term'
    return 2 if timeframe == 'medium_term'
    return 1 if timeframe == 'short_term'
    return 0
  end
end
