require_relative '../../lib/constants'
require 'pry-byebug'

class SpotifyDatabaseActions
  # the require brings the file in
  # thence we can use contents ie Constants::TERMS
  include Constants
  # by using include
  # we can directly use the contents of Constants eg LIMIT

  def initialize(user, spotify_client)
    @user = user
    @spotify_client = spotify_client
  end

  def write_user_top_tracks 
    TopTrack.destroy_by(user_id: @user.id)

    TERMS.each do |timeframe|
      top_tracks(timeframe).each do |track|
        write_new_top_track(@user, track, timeframe)
      end
    end
  end

  def track_audio_features(track_id)
    @spotify_client.track_audio_features(track_id)
  end

  def write_user_top_artists
    TopArtist.destroy_by(user_id: @user.id)

    TERMS.each do |timeframe|
      top_artists(timeframe).each do |artist|
        # don't create a new artist if that artist already exists in the db
        existing_artist = @user.top_artists.find_by(artist_id: artist[:artist_id])

        add_or_modify_artist(existing_artist, timeframe, artist)
      end
    end
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

  private

  def write_new_top_track(user, track, timeframe)
    t = TopTrack.new
    t[:artist] = track[:artist]
    t[:artist_id] = track[:artist_id]
    t[:album] = track[:album]
    t[:track] = track[:track]
    t[:popularity] = track[:popularity]
    t[:timeframe] = timeframe
    t[:user_id] = user.id
    t[:track_id] = track[:id]
    t.save
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
      .sort_by { |hsh| hsh[:popularity] }
      .reject { |hsh| hsh[:artist] == 'Various Artists' }
  end



  def add_or_modify_artist(existing_artist, timeframe, artist)
    if existing_artist
      add_score_to_existing_artist(existing_artist, timeframe)
    else
      add_new_top_artist(@user, artist, timeframe)
    end
  end

  def add_score_to_existing_artist(artist, timeframe)
    artist[:score] = artist[:score] + artist_timeframe_score(timeframe)
    artist[:timeframe] = 'multiple'
    artist.save
  end

  def add_new_top_artist(user, artist, timeframe)
    t = TopArtist.new
    t[:artist] = artist[:artist]
    t[:timeframe] = timeframe
    t[:user_id] = user.id
    t[:artist_id] = artist[:artist_id]
    t[:score] = artist_timeframe_score(timeframe)
    t.save
  end

  def artist_timeframe_score(timeframe)
    return 8 if timeframe == 'long_term'
    return 6 if timeframe == 'medium_term'
    return 3 if timeframe == 'short_term'
    0
  end

  def top_artists(term)
    @spotify_client
      .me_top_artists(time_range: term, limit: LIMIT)["items"]
      .map{ |item| {
        artist: item['name'],
        artist_id: item['id']
      }
    }.reject{ |hsh| hsh[:artist] == 'Various Artists' }
  end


  def artist_score_from_track(timeframe)
    return 3 if timeframe == 'long_term'
    return 2 if timeframe == 'medium_term'
    return 1 if timeframe == 'short_term'
    return 0
  end
end



