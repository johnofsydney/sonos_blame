class HomeController < ApplicationController
  def index
    # all_tracks = TopTrack.all
    @top_track = TopTrack.all
      .map{ |t| t[:track] }
      .group_by(&:itself)
      .transform_values(&:count)
      .sort_by{ |k,v| v }
      .reverse.first.first

    @top_artist = TopTrack.all
      .map{ |t| t[:artist] }
      .group_by(&:itself)
      .transform_values(&:count)
      .sort_by{ |k,v| v }
      .reverse.first.first

    @user_top_artist = current_user.top_tracks.all
      .map{ |t| t[:artist] }
      .group_by(&:itself)
      .transform_values(&:count)
      .sort_by{ |k,v| v }
      .reverse.first.first
  end
end
