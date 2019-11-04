require 'pry-byebug'

class SpotifyController < ApplicationController

  def index
    @params = whitelist_params
  end


  private
  def whitelist_params
    params.permit(:query, :commit)
  end
end
