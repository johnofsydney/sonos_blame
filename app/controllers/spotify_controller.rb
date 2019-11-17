require 'spotify_search_actions'
require 'spotify_playlist_actions'

class SpotifyController < ApplicationController

  def results
    @band_name = whitelist_search_params[:query]

    # send it to spotify
    # and retrieve the artist_id
    access_token = session[:access_token]
    search = SpotifySearchActions.new(current_user, access_token)
    results = search.search_artist(@band_name)

    if results['artists']['items'].first.nil?
      # the band can't be found on spotify. give up.
      redirect_to '/spotify/unknown' 
      return
    end

    # spotify id for th artist searched for
    artist_id = results['artists']['items'].first['id']
    @artist_name = results['artists']['items'].first['name']

    # query the database for this specific artist_id,
    # return a list of users and scores...
    list = TopArtist
            .where(artist_id: artist_id)
            .sort_by{ |row| row[:score] }
            .reverse

    # can we find a clear winner on actual listens?
    unless list.nil? 
      # only one listener and score is > 15
      if list.count == 1 && list.first[:score] > 15
        @winner = list.first.user.name
        @suspects = []
        @explanation = "Not only is #{@winner} the only user who has been known to listen to #{@artist_name}, they have listened to enough of #{@artist_name}'s music that further investigation was not required."
        @confidence = 'High'
        return
      end

      # more listeners, but large gap
      if list.count > 1 && list.first[:score] > 30 && list[1][:score] < 15
        @winner = list.shift.user.name
        @suspects = list.map{ |a| a.user.name }
        @explanation = "Although all of the suspects listed above have a  history of listening to #{@artist_name}, there was daylight between #{@winner} and #{@suspects.first} in the amount of spotify plays of #{@artist_name}"
        @confidence = 'High'
        return
      end
    end



    related_artists = search.related_artists(artist_id)["artists"]
                    .map{ |a| {name: a["name"], id: a["id"], popularity: a["popularity"]} }
                    .sort_by{ |a| a[:popularity] }
                    .reverse
                    .take(10)

    artist_ids = related_artists.map{ |hsh| hsh[:id] } + [artist_id]
    related_artist_names = related_artists.map{ |a| a[:name] }

    # at this stage we don't have a clear winner based on actual listens
    # retrieve records for the searched artist and their associated artists
    list = TopArtist.where(artist_id: artist_ids )

    # group by user_id, sort by score
    list =  list
            .group_by{ |row| row["user_id"] }
            .map do |user_id, users_rows| 
              {
                user_id: user_id,
                user_name: User.find(user_id).name,
                score: (
                  users_rows.reduce(0){ |acc, row| acc + row['score'] }
                )
              }
            end
            .sort_by{ |row| row[:score] }
            .reverse

    if list.nil? || list.empty?
      # the band can't be found in TopArtists. give up.
      redirect_to '/spotify/unknown' 
      return
    end

    first_score = list.first[:score]
    if list[1]
      second_score = list[1][:score] || 0
    else
      second_score = 0
    end

    @winner = list.shift[:user_name]
    @suspects = list.map{ |u| u[:user_name] }
    @explanation = "As well as searching for playing history for #{@artist_name}, the following related artists were also examined => #{related_artist_names}"
    @confidence = case (first_score - second_score)
      when 0..5 then 'Not overwhelming...'
      when 6..10 then 'Quite'
      when 11..20 then 'High'
      else 'Totally'
    end
    
    return
  end


  def unknown
  end

  def recommendations_all
    params = whitelist_recommend_params.to_h.with_indifferent_access

    seeds = TopArtist
            .where(user_id: current_user.id)
            .sort_by{ |h| h.score }
            .reverse
            .take(40)
            .shuffle
            .take(5)
            .map{ |a| {id: a.artist_id, name: a.artist} }


    access_token = session[:access_token]
    client = SpotifyPlaylistActions.new(current_user, access_token)
    options = {
      seed_artists: seeds.map{ |s| s[:id] }, 
      max_acousticness: params[:acousticness][:max].to_f,
      min_acousticness: params[:acousticness][:min].to_f,
      max_danceability: params[:danceability][:max].to_f,
      min_danceability: params[:danceability][:min].to_f,
      max_energy: params[:energy][:max].to_f,
      min_energy: params[:energy][:min].to_f,
      max_instrumentalness: params[:instrumentalness][:max].to_f,
      min_instrumentalness: params[:instrumentalness][:min].to_f,
      max_valence: params[:valence][:max].to_f,
      min_valence: params[:valence][:min].to_f,
      max_popularity: params[:popularity][:max].to_i,
      min_popularity: params[:popularity][:min].to_i
    }


    name = "sonos-blame-#{Time.now.to_formatted_s(:db).gsub(' ','-')}"
    playlist = client.make_playlist(name)

    playlist_object = client.get_recommendations_from_artists(options)    
    uris = playlist_object['tracks'].map{ |track| track['uri'] }
    result = client.add_tracks_to_playlist(playlist['id'], uris)

    @initial_pool_size = playlist_object["seeds"].first["initialPoolSize"]
    @after_filtering_size = playlist_object["seeds"].first["afterFilteringSize"]

    @artists = seeds.map{ |s| s[:name] }
    @playlist_url = playlist['external_urls']['spotify']

  end

  private
  def whitelist_search_params
    params.permit(:query, :commit)
  end

  def whitelist_recommend_params
    params.permit(
      acousticness: {},
      danceability: {},
      energy: {},
      instrumentalness: {},
      valence: {}, 
      popularity: {}
      )
  end
end
