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

    # query the database for this specific artist_id,
    # return a list of users and scores...
    list = TopArtist
            .where(artist_id: artist_id)
            .sort_by{ |row| row[:score] }

    # can we find a clear winner on actual listens?
    unless list.nil? 
      # only one listener and score is > 15
      if list.count == 1 && list.first[:score] > 15
        winner = list.first
      end

      # more listeners, but large gap
      if list.count > 1 && list.first[:score] > 20 && list[1][:score] < 10
        winner = list.first
        list.shift
        suspects = list
      end
    end



    related_artists = search.related_artists(artist_id)["artists"]
                    .map{ |a| {name: a["name"], id: a["id"], popularity: a["popularity"]} }
                    .sort_by{ |a| a[:popularity] }
                    .reverse
                    .take(5)

    artist_ids = related_artists.map{ |hsh| hsh[:id] } + [artist_id]

    # at this stage we don't have a clear winner based on actual listens
    # retrieve records for the searched artist and their associated artists
    list = TopArtist.where(artist_id: artist_ids )

    # group by user_id, sort by score
    user_scores = list
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

    binding.pry

 






    # # and map and sort it for return
    # @list.map{ |row| {
    #                     name: row.user.name,
    #                     score: row.score
    #             } 
    #           }
    #       .sort_by{ |row| row[:score] }
    #       .reverse
  end


  def unknown
  end

  private
  def whitelist_params
    params.permit(:query, :commit)
  end
end
