require 'pry-byebug'
require 'spotify_search_actions'

class SpotifyController < ApplicationController

  def results
    @band_name = whitelist_params[:query]

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
                    .take(5)

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

  private
  def whitelist_params
    params.permit(:query, :commit)
  end
end
