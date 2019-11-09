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
      redirect_to '/spotify/unknown' 
      return
    end

    
    artist_id = results['artists']['items'].first['id']
    
    
    # query the database for this artist_id, return a list
    @list = TopArtist.where(artist_id: artist_id)

    # and map and sort it for return
    @list.map{ |row| {
                        name: row.user.name,
                        score: row.score
                } 
              }
          .sort_by{ |row| row[:score] }
          .reverse
  end


  def unknown
  end

  private
  def whitelist_params
    params.permit(:query, :commit)
  end
end
