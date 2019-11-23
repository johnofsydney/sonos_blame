
class UsersController < ApplicationController

  def show
    # restrict user data  - you can only see your own data
    @user = current_user

    short_termers = @user.top_tracks.where(timeframe: 'short_term')
    medium_termers = @user.top_tracks.where(timeframe: 'medium_term')
    long_termers = @user.top_tracks.where(timeframe: 'long_term')

    # @collections = [@short_termers, @medium_termers, @long_termers].compact

    @collections = []
    @collections.push(short_termers) unless short_termers.nil? || short_termers.empty?
    @collections.push(medium_termers) unless medium_termers.nil? || medium_termers.empty?
    @collections.push(long_termers) unless long_termers.nil? || long_termers.empty?

    if @user.top_artists
      @top_artists = @user.top_artists.sort_by{ |hsh| hsh[:score] }.reverse
    end
  end
end
