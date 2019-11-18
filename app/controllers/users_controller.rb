
class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @short_termers = @user.top_tracks.where(timeframe: 'short_term')
    @medium_termers = @user.top_tracks.where(timeframe: 'medium_term')
    @long_termers = @user.top_tracks.where(timeframe: 'long_term')

    @collections = [@short_termers, @medium_termers, @long_termers].compact

    if @user.top_artists
      @top_artists = @user.top_artists.sort_by{ |hsh| hsh[:score] }.reverse
    end
  end
end
